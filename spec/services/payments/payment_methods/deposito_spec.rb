require 'rails_helper'

RSpec.describe Payments::PaymentMethods::Deposito, type: :service do
  let(:customer) { create(:customer, name: "João Silva", email: "joao@test.com") }
  let(:payment_method) { described_class.new }
  let(:amount) { 100.0 }

  describe '#charge' do
    context 'with valid parameters' do
      it 'processes payment successfully' do
        result = payment_method.charge(customer, amount)

        expect(result[:success]).to be true
        expect(result[:transaction_id]).to start_with('DEP_')
        expect(result[:details][:payment_method]).to eq('Depósito Bancário')
        expect(result[:details][:banco]).to eq('Banco do Brasil')
      end

      it 'generates unique transaction IDs' do
        result1 = payment_method.charge(customer, amount)
        result2 = payment_method.charge(customer, amount)

        expect(result1[:transaction_id]).not_to eq(result2[:transaction_id])
      end

      it 'logs payment processing' do
        expect { payment_method.charge(customer, amount) }
          .to output(/💰 DEPÓSITO PROCESSADO/).to_stdout
      end
    end

    context 'with invalid parameters' do
      it 'handles invalid inputs gracefully' do
        result = payment_method.charge(nil, amount)
        expect(result[:success]).to be false
        expect(result[:error]).to be_present
      end
    end

    context 'when payment processing fails' do
      before do
        allow(payment_method).to receive(:generate_transaction_id).and_raise(StandardError, "Banco indisponível")
      end

      it 'returns failure response' do
        result = payment_method.charge(customer, amount)

        expect(result[:success]).to be false
        expect(result[:error]).to eq("Banco indisponível")
        expect(result[:details][:payment_method]).to eq('Depósito Bancário')
      end
    end
  end

  describe '.display_name' do
    it 'returns correct display name' do
      expect(described_class.display_name).to eq('Depósito Bancário')
    end
  end

  describe 'inheritance' do
    it 'inherits from Payments::Base' do
      expect(described_class.superclass).to eq(Payments::Base)
    end
  end
end