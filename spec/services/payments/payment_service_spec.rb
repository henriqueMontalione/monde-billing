require 'rails_helper'

RSpec.describe Payments::PaymentService do
  describe '.available_methods' do
    it 'discovers all payment methods via directory scanning' do
      methods = described_class.available_methods
      
      expect(methods).to be_a(Hash)
      expect(methods.keys).to include('boleto', 'credit_card', 'pix')
      expect(methods['boleto']).to eq(Payments::PaymentMethods::Boleto)
      expect(methods['credit_card']).to eq(Payments::PaymentMethods::CreditCard)
      expect(methods['pix']).to eq(Payments::PaymentMethods::Pix)
    end
  end
  
  describe '.find_method' do
    it 'returns instance of correct payment method' do
      boleto = described_class.find_method('boleto')
      expect(boleto).to be_a(Payments::PaymentMethods::Boleto)
    end
    
    it 'returns nil for invalid payment method' do
      invalid = described_class.find_method('invalid_method')
      expect(invalid).to be_nil
    end
  end
  
  describe '.options_for_select' do
    it 'returns array of options for form select' do
      options = described_class.options_for_select
      
      expect(options).to be_a(Array)
      expect(options).to include(['Boleto', 'boleto'])
      expect(options).to include(['Pix', 'pix'])
      expect(options).to include(['Depósito Bancário', 'deposito'])
      expect(options.size).to eq(4)
    end
  end
  
  describe '.method_exists?' do
    it 'returns true for existing payment method' do
      expect(described_class.method_exists?('boleto')).to be true
      expect(described_class.method_exists?('pix')).to be true
    end
    
    it 'returns false for non-existing payment method' do
      expect(described_class.method_exists?('invalid')).to be false
    end
  end
  
  describe '.process_payment' do
    let(:customer) { build(:customer, payment_method_type: 'boleto') }
    
    it 'processes payment using correct payment method' do
      result = described_class.process_payment(customer, 100.0)
      
      expect(result).to be_a(Hash)
      expect(result[:status]).to eq(:success)
      expect(result[:transaction_id]).to start_with('BOL_')
    end
    
    it 'raises error for invalid payment method' do
      customer.payment_method_type = 'invalid_method'
      
      expect {
        described_class.process_payment(customer, 100.0)
      }.to raise_error(Payments::PaymentError, /Payment method not found/)
    end
  end
end
