require 'rails_helper'

RSpec.describe BillingRecord, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      billing_record = build(:billing_record)
      expect(billing_record).to be_valid
    end
    
    it 'validates uniqueness of month scoped to customer and year' do
      existing_record = create(:billing_record, month: 1, year: 2024)
      duplicate_record = build(:billing_record, 
                              customer: existing_record.customer,
                              month: 1, 
                              year: 2024)
      
      expect(duplicate_record).not_to be_valid
      expect(duplicate_record.errors[:month]).to include('cliente já foi faturado neste período')
    end
  end
  
  describe 'enums' do
    it 'defines status enum correctly' do
      expect(BillingRecord.statuses).to eq({
        'pending' => 0,
        'processing' => 1,
        'success' => 2,
        'failed' => 3
      })
    end
  end
  
  describe '#can_retry?' do
    it 'returns true for failed status' do
      record = build(:billing_record, :failed)
      expect(record.can_retry?).to be true
    end
    
    it 'returns false for success status' do
      record = build(:billing_record, :successful)
      expect(record.can_retry?).to be false
    end
  end
end
