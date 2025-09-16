require 'rails_helper'

RSpec.describe Payments::PaymentMethods::Boleto do
  let(:customer) { build(:customer) }
  let(:amount) { 100.0 }
  let(:boleto) { described_class.new }
  
  describe '#charge' do
    it 'processes boleto payment successfully' do
      result = boleto.charge(customer, amount)
      
      expect(result).to be_a(Hash)
      expect(result[:status]).to eq(:success)
      expect(result[:transaction_id]).to start_with('BOL_')
      expect(result[:barcode]).to be_present
      expect(result[:due_date]).to be_a(Date)
      expect(result[:boleto_url]).to include('banco.exemplo.com/boleto/')
    end
    
    it 'generates unique transaction IDs' do
      result1 = boleto.charge(customer, amount)
      result2 = boleto.charge(customer, amount)
      
      expect(result1[:transaction_id]).not_to eq(result2[:transaction_id])
    end
    
    it 'sets due date to 3 days from now' do
      result = boleto.charge(customer, amount)
      expected_date = Date.current + 3.days
      
      expect(result[:due_date]).to eq(expected_date)
    end
    
    it 'generates barcode in correct format' do
      result = boleto.charge(customer, amount)
      barcode = result[:barcode]
      
      # Verifica formato básico da linha digitável
      expect(barcode).to match(/\d{5}\.\d{5} \d{5}\.\d{6} \d{5}\.\d{6} \d \d{14}/)
    end
    
    it 'creates boleto URL with transaction ID' do
      result = boleto.charge(customer, amount)
      
      expect(result[:boleto_url]).to eq("https://banco.exemplo.com/boleto/#{result[:transaction_id]}")
    end
    
    it 'validates customer and amount via parent class' do
      expect {
        boleto.charge(nil, amount)
      }.to raise_error(ArgumentError, /Customer cannot be blank/)
      
      expect {
        boleto.charge(customer, -10)
      }.to raise_error(ArgumentError, /Amount must be positive/)
    end
  end
  
  describe 'display_name' do
    it 'returns correct display name' do
      expect(described_class.display_name).to eq('Boleto')
    end
  end
  
  describe 'private methods' do
    describe '#generate_barcode' do
      it 'generates valid barcode format' do
        barcode = boleto.send(:generate_barcode)
        
        expect(barcode).to be_a(String)
        expect(barcode).to match(/\d{5}\.\d{5} \d{5}\.\d{6} \d{5}\.\d{6} \d \d{14}/)
      end
      
      it 'generates unique barcodes' do
        barcode1 = boleto.send(:generate_barcode)
        barcode2 = boleto.send(:generate_barcode)
        
        expect(barcode1).not_to eq(barcode2)
      end
    end
    
    describe '#calculate_due_date' do
      it 'returns date 3 days from now' do
        expected_date = Date.current + 3.days
        actual_date = boleto.send(:calculate_due_date)
        
        expect(actual_date).to eq(expected_date)
      end
    end
  end
end
