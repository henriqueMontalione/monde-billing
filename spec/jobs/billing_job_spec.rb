require 'rails_helper'

RSpec.describe BillingJob, type: :job do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  let(:today) { Date.new(2024, 1, 15) }
  let!(:customer) do
    create(:customer,
           name: "João Silva",
           billing_day: 15,
           payment_method_type: "boleto")
  end

  before do
    travel_to today
  end

  after do
    travel_back
  end

  describe '#perform' do
    it 'processes billing for given date' do
      expect(Billing::BillingService).to receive(:process_billing_for_date)
        .with(today)
        .and_return({ success: [customer], failed: [], skipped: [] })

      BillingJob.new.perform(today)
    end

    it 'schedules retry job when there are failures' do
      allow(Billing::BillingService).to receive(:process_billing_for_date)
        .and_return({
          success: [],
          failed: [{ customer: customer, details: { error: 'Payment failed' } }],
          skipped: []
        })

      expect {
        BillingJob.new.perform(today)
      }.to have_enqueued_job(RetryFailedPaymentsJob).at(2.hours.from_now)
    end

    it 'does not schedule retry job when all payments succeed' do
      allow(Billing::BillingService).to receive(:process_billing_for_date)
        .and_return({ success: [customer], failed: [], skipped: [] })

      expect {
        BillingJob.new.perform(today)
      }.not_to have_enqueued_job(RetryFailedPaymentsJob)
    end

    it 'logs billing results' do
      allow(Billing::BillingService).to receive(:process_billing_for_date)
        .and_return({ success: [customer], failed: [], skipped: [] })

      expect(Rails.logger).to receive(:info).at_least(:once)

      BillingJob.new.perform(today)
    end

    it 'handles errors gracefully' do
      allow(Billing::BillingService).to receive(:process_billing_for_date)
        .and_raise(StandardError, 'Database error')

      expect(Rails.logger).to receive(:error).with(/Erro no BillingJob/)
      expect(Rails.logger).to receive(:error)

      expect {
        BillingJob.new.perform(today)
      }.to raise_error(StandardError, 'Database error')
    end
  end

  describe 'queue configuration' do
    it 'is queued in billing queue' do
      expect(BillingJob.new.queue_name).to eq('billing')
    end
  end
end