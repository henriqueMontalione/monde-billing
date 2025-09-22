require 'rails_helper'

RSpec.describe Billing::BillingService do
  describe '.process_billing_for_date' do
    let(:billing_date) { Date.new(2024, 3, 15) }

    context 'when there are customers to bill' do
      let!(:customer1) { create(:customer, billing_day: 15, payment_method_type: 'boleto') }
      let!(:customer2) { create(:customer, billing_day: 15, payment_method_type: 'credit_card') }
      let!(:customer3) { create(:customer, billing_day: 10, payment_method_type: 'pix') } # Não deve ser cobrado

      it 'processes billing for customers with matching billing day' do
        results = described_class.process_billing_for_date(billing_date)

        expect(results[:success].count).to eq(2)
        expect(results[:failed]).to be_empty
        expect(results[:skipped]).to be_empty

        expect(BillingRecord.count).to eq(2)
        expect(BillingRecord.where(month: 3, year: 2024).count).to eq(2)
      end

      it 'includes customers with end-of-month billing days when date >= 28' do
        billing_date = Date.new(2024, 2, 29)
        customer_end_month = create(:customer, billing_day: 31, payment_method_type: 'boleto')

        results = described_class.process_billing_for_date(billing_date)

        expect(results[:success].count).to eq(1)
        expect(BillingRecord.where(customer: customer_end_month).count).to eq(1)
      end
    end

    context 'when customers are already billed' do
      let!(:customer) { create(:customer, billing_day: 15, payment_method_type: 'boleto') }
      let!(:existing_billing) { create(:billing_record, customer: customer, month: 3, year: 2024, status: :success) }

      it 'excludes already billed customers from processing' do
        results = described_class.process_billing_for_date(billing_date)

        expect(results[:success]).to be_empty
        expect(results[:failed]).to be_empty
        expect(results[:skipped]).to be_empty

        expect(BillingRecord.where(customer: customer, month: 3, year: 2024).count).to eq(1)
      end
    end

    context 'when payment processing fails' do
      let!(:customer) { create(:customer, billing_day: 15, payment_method_type: 'boleto') }

      before do
        allow(Payments::PaymentService).to receive(:process_payment).and_raise(Payments::PaymentError, 'Gateway timeout')
      end

      it 'records failed billing attempts' do
        results = described_class.process_billing_for_date(billing_date)

        expect(results[:success]).to be_empty
        expect(results[:failed].count).to eq(1)
        expect(results[:skipped]).to be_empty

        billing_record = BillingRecord.last
        expect(billing_record.status).to eq('failed')
        expect(billing_record.error_message).to be_present
      end
    end
  end

  describe '.process_customer_billing' do
    let(:customer) { create(:customer, billing_day: 15, payment_method_type: 'boleto') }
    let(:billing_date) { Date.new(2024, 3, 15) }

    context 'when customer has not been billed this month' do
      it 'creates billing record and processes payment' do
        result = described_class.process_customer_billing(customer, billing_date)

        expect(result[:status]).to eq(:success)
        expect(result[:billing_record]).to be_a(BillingRecord)
        expect(result[:payment_result]).to be_a(Hash)

        billing_record = result[:billing_record]
        expect(billing_record.customer).to eq(customer)
        expect(billing_record.month).to eq(3)
        expect(billing_record.year).to eq(2024)
        expect(billing_record.amount).to eq(99.90)
        expect(billing_record.status).to eq('success')
        expect(billing_record.transaction_id).to be_present
      end
    end

    context 'when customer was already billed this month' do
      let!(:existing_billing) { create(:billing_record, customer: customer, month: 3, year: 2024) }

      it 'skips billing and returns appropriate message' do
        result = described_class.process_customer_billing(customer, billing_date)

        expect(result[:status]).to eq(:skipped)
        expect(result[:message]).to include('já faturado para 3/2024')
      end
    end

    context 'when payment processing fails' do
      let(:customer) { create(:customer, billing_day: 15, payment_method_type: 'boleto') }

      before do
        allow(Payments::PaymentService).to receive(:process_payment).and_raise(Payments::PaymentError, 'Gateway timeout')
      end

      it 'creates failed billing record with error details' do
        result = described_class.process_customer_billing(customer, billing_date)

        expect(result[:status]).to eq(:failed)
        expect(result[:billing_record].status).to eq('failed')
        expect(result[:billing_record].error_message).to be_present
        expect(result[:error]).to be_a(StandardError)
      end
    end
  end

  describe '.retry_billing' do
    let(:customer) { create(:customer, payment_method_type: 'boleto') }

    context 'with a failed billing record' do
      let(:billing_record) { create(:billing_record, customer: customer, status: :failed, error_message: 'Gateway timeout') }

      it 'retries the payment and updates record on success' do
        result = described_class.retry_billing(billing_record)

        expect(result[:status]).to eq(:success)

        billing_record.reload
        expect(billing_record.status).to eq('success')
        expect(billing_record.transaction_id).to be_present
        expect(billing_record.error_message).to eq('Gateway timeout') # Preserva erro anterior
      end
    end

    context 'with a pending billing record' do
      let(:billing_record) { create(:billing_record, customer: customer, status: :pending) }

      it 'processes the pending billing' do
        result = described_class.retry_billing(billing_record)

        expect(result[:status]).to eq(:success)
        expect(billing_record.reload.status).to eq('success')
      end
    end

    context 'with a successful billing record' do
      let(:billing_record) { create(:billing_record, customer: customer, status: :success) }

      it 'raises error when trying to retry successful billing' do
        expect {
          described_class.retry_billing(billing_record)
        }.to raise_error(Billing::BillingService::BillingError, /cannot be retried/)
      end
    end

    context 'when retry also fails' do
      let(:customer) { create(:customer, payment_method_type: 'boleto') }
      let(:billing_record) { create(:billing_record, customer: customer, status: :failed) }

      before do
        allow(Payments::PaymentService).to receive(:process_payment).and_raise(Payments::PaymentError, 'Gateway timeout')
      end

      it 'updates billing record with new failure' do
        result = described_class.retry_billing(billing_record)

        expect(result[:status]).to eq(:failed)

        billing_record.reload
        expect(billing_record.status).to eq('failed')
        expect(billing_record.error_message).to be_present
      end
    end
  end

  describe 'integration scenarios' do
    let(:customer) { create(:customer, billing_day: 15, payment_method_type: 'credit_card') }

    it 'handles end-of-month billing correctly' do
      customer.update!(billing_day: 31)
      february_date = Date.new(2023, 2, 28)

      results = described_class.process_billing_for_date(february_date)
      expect(results[:success].count).to eq(1)
    end

    it 'prevents duplicate billing' do
      described_class.process_customer_billing(customer)

      result = described_class.process_customer_billing(customer)
      expect(result[:status]).to eq(:skipped)
    end
  end
end