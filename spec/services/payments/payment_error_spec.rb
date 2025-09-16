require 'rails_helper'

RSpec.describe Payments::PaymentError do
  describe 'inheritance' do
    it 'inherits from StandardError' do
      expect(described_class.superclass).to eq(StandardError)
    end
  end
  
  describe 'initialization' do
    it 'can be initialized with a message' do
      error = described_class.new("Payment failed")
      
      expect(error.message).to eq("Payment failed")
      expect(error).to be_a(StandardError)
    end
    
    it 'can be initialized without message' do
      error = described_class.new
      
      expect(error).to be_a(StandardError)
    end
  end
  
  describe 'usage in rescue blocks' do
    it 'can be rescued as StandardError' do
      expect {
        begin
          raise described_class, "Test error"
        rescue StandardError => e
          expect(e).to be_a(described_class)
          expect(e.message).to eq("Test error")
          raise # re-raise to trigger outer expect
        end
      }.to raise_error(described_class)
    end
    
    it 'can be rescued specifically' do
      expect {
        begin
          raise described_class, "Specific error"
        rescue described_class => e
          expect(e.message).to eq("Specific error")
          raise # re-raise to trigger outer expect
        end
      }.to raise_error(described_class)
    end
  end
end
