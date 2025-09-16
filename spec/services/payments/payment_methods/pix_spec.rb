require 'rails_helper'

RSpec.describe Payments::PaymentMethods::Pix do
  let(:customer) { build(:customer) }
  let(:amount) { 100.0 }
  let(:pix) { described_class.new }
  
  describe '#charge' do
    it 'processes PIX payment successfully' do
      result = pix.charge(customer, amount)
      
      expect(result).to be_a(Hash)
      expect(result[:status]).to eq(:success)
      expect(result[:transaction_id]).to start_with('PIX_')
      expect(result[:end_to_end_id]).to start_with('E')
      expect(result[:transferred_at]).to be_a(Time)
    end
    
    it 'generates unique transaction IDs' do
      result1 = pix.charge(customer, amount)
      result2 = pix.charge(customer, amount)
      
      expect(result1[:transaction_id]).not_to eq(result2[:transaction_id])
    end
    
    it 'generates unique end-to-end IDs' do
      result1 = pix.charge(customer, amount)
      result2 = pix.charge(customer, amount)
      
      expect(result1[:end_to_end_id]).not_to eq(result2[:end_to_end_id])
    end
    
    it 'validates customer and amount' do
      expect {
        pix.charge(nil, amount)
      }.to raise_error(ArgumentError, /Customer cannot be blank/)
      
      expect {
        pix.charge(customer, -10)
      }.to raise_error(ArgumentError, /Amount must be positive/)
    end
  end
  
  describe '.display_name' do
    it 'returns correct display name' do
      expect(described_class.display_name).to eq('Pix')
    end
  end
  
  describe 'private methods' do
    describe '#generate_end_to_end_id' do
      it 'generates end-to-end ID with correct format' do
        e2e_id = pix.send(:generate_end_to_end_id)
        
        expect(e2e_id).to start_with('E')
        expect(e2e_id.length).to eq(28)
        expect(e2e_id).to match(/^E\d{8}\d{8}[A-Z0-9]{11}$/)
      end
      
      it 'includes ISPB code in correct position' do
        e2e_id = pix.send(:generate_end_to_end_id)
        ispb_part = e2e_id[1, 8] # Characters 1-8 after 'E'
        
        expect(ispb_part).to eq('12345678')
      end
      
      it 'includes date in correct format' do
        e2e_id = pix.send(:generate_end_to_end_id)
        date_part = e2e_id[9, 8] # Characters 9-16
        expected_date = Time.current.strftime('%Y%m%d')
        
        expect(date_part).to eq(expected_date)
      end
      
      it 'generates unique end-to-end IDs' do
        e2e_id1 = pix.send(:generate_end_to_end_id)
        e2e_id2 = pix.send(:generate_end_to_end_id)
        
        expect(e2e_id1).not_to eq(e2e_id2)
      end
    end
  end
end
