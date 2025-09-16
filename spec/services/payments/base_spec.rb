require 'rails_helper'

RSpec.describe Payments::Base do
  let(:customer) { build(:customer) }
  let(:amount) { 100.0 }
  
  describe '#charge' do
    it 'raises NotImplementedError when not overridden' do
      base_instance = described_class.new
      
      expect {
        base_instance.charge(customer, amount)
      }.to raise_error(NotImplementedError, "Subclass must implement #charge method")
    end
    
    it 'validates customer presence' do
      base_instance = described_class.new
      
      expect {
        base_instance.charge(nil, amount)
      }.to raise_error(ArgumentError, "Customer cannot be blank")
    end
    
    it 'validates customer type' do
      base_instance = described_class.new
      
      expect {
        base_instance.charge("invalid", amount)
      }.to raise_error(ArgumentError, /Expected Customer object/)
    end
    
    it 'validates amount presence' do
      base_instance = described_class.new
      
      expect {
        base_instance.charge(customer, nil)
      }.to raise_error(ArgumentError, /Amount must be positive number/)
    end
    
    it 'validates amount is positive' do
      base_instance = described_class.new
      
      expect {
        base_instance.charge(customer, -10)
      }.to raise_error(ArgumentError, /Amount must be positive number/)
      
      expect {
        base_instance.charge(customer, 0)
      }.to raise_error(ArgumentError, /Amount must be positive number/)
    end
  end
  
  describe '.display_name' do
    it 'returns humanized class name' do
      expect(Payments::PaymentMethods::CreditCard.display_name).to eq("Creditcard")
      expect(Payments::PaymentMethods::Boleto.display_name).to eq("Boleto")
      expect(Payments::PaymentMethods::Pix.display_name).to eq("Pix")
    end
  end
  
  describe '#generate_transaction_id' do
    it 'generates unique transaction ID with prefix' do
      base_instance = described_class.new
      
      # Access protected method for testing
      id1 = base_instance.send(:generate_transaction_id, "TEST")
      id2 = base_instance.send(:generate_transaction_id, "TEST")
      
      expect(id1).to start_with("TEST_")
      expect(id2).to start_with("TEST_")
      expect(id1).not_to eq(id2)
      expect(id1.length).to eq(21)
    end
  end
end
