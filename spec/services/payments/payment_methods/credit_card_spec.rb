require 'rails_helper'

RSpec.describe Payments::PaymentMethods::CreditCard do
  let(:customer) { build(:customer) }
  let(:amount) { 100.0 }
  let(:credit_card) { described_class.new }
  
  describe '#charge' do
    it 'processes credit card payment successfully' do
      result = credit_card.charge(customer, amount)
      
      expect(result).to be_a(Hash)
      expect(result[:status]).to eq(:success)
      expect(result[:transaction_id]).to start_with('CC_')
      expect(result[:authorization_code]).to start_with('AUTH_')
      expect(result[:charged_at]).to be_a(Time)
    end
    
    it 'generates unique transaction IDs' do
      result1 = credit_card.charge(customer, amount)
      result2 = credit_card.charge(customer, amount)
      
      expect(result1[:transaction_id]).not_to eq(result2[:transaction_id])
    end
    
    it 'generates unique authorization codes' do
      result1 = credit_card.charge(customer, amount)
      result2 = credit_card.charge(customer, amount)
      
      expect(result1[:authorization_code]).not_to eq(result2[:authorization_code])
    end
    
    it 'validates customer and amount' do
      expect {
        credit_card.charge(nil, amount)
      }.to raise_error(ArgumentError, /Customer cannot be blank/)
      
      expect {
        credit_card.charge(customer, -10)
      }.to raise_error(ArgumentError, /Amount must be positive/)
    end
  end
  
  describe '.display_name' do
    it 'returns correct display name' do
      expect(described_class.display_name).to eq('Creditcard')
    end
  end
  
  describe 'private methods' do
    describe '#generate_authorization_code' do
      it 'generates authorization code with correct format' do
        auth_code = credit_card.send(:generate_authorization_code)
        
        expect(auth_code).to start_with('AUTH_')
        expect(auth_code.length).to eq(17)
        expect(auth_code).to match(/^AUTH_[A-F0-9]{12}$/)
      end
      
      it 'generates unique authorization codes' do
        code1 = credit_card.send(:generate_authorization_code)
        code2 = credit_card.send(:generate_authorization_code)
        
        expect(code1).not_to eq(code2)
      end
    end
  end
end
