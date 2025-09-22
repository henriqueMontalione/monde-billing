require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      customer = build(:customer)
      expect(customer).to be_valid
    end
    
    it 'validates presence of required fields' do
      customer = Customer.new
      expect(customer).not_to be_valid
      expect(customer.errors.attribute_names).to include(:name, :email, :billing_day, :payment_method_type)
    end
    
    it 'validates email uniqueness' do
      existing_customer = create(:customer, email: 'test@example.com')
      duplicate_customer = build(:customer, email: 'test@example.com')
      
      expect(duplicate_customer).not_to be_valid
      expect(duplicate_customer.errors[:email]).to include('já está em uso')
    end
    
    it 'validates billing_day range' do
      customer = build(:customer, billing_day: 32)
      expect(customer).not_to be_valid
      
      customer = build(:customer, billing_day: 0)
      expect(customer).not_to be_valid
    end
  end
  
  describe '#effective_billing_day' do
    it 'returns billing_day when month has enough days' do
      customer = build(:customer, billing_day: 15)
      effective_day = customer.effective_billing_day(Date.new(2024, 1, 1))
      expect(effective_day).to eq(15)
    end
    
    it 'returns last day of month when billing_day exceeds month days' do
      customer = build(:customer, billing_day: 31)
      
      # Feb has 29 days in 2024
      effective_day = customer.effective_billing_day(Date.new(2024, 2, 1)) 
      expect(effective_day).to eq(29)
    end
  end
end
