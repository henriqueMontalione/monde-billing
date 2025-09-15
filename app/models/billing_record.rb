class BillingRecord < ApplicationRecord
  belongs_to :customer
  
  enum status: {
    pending: 0,   
    processing: 1,
    success: 2,
    failed: 3   
  }
  
  validates :month, presence: true, inclusion: { in: 1..12 }
  validates :year, presence: true
  validates :processed_at, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  
  # Validação de idempotência
  validates :month, uniqueness: { 
    scope: [:customer_id, :year], 
    message: "cliente já foi faturado neste período" 
  }

  def period_description
    Date.new(year, month).strftime("%B %Y")
  end
  
  def processed_day_description
    processed_at.strftime("%d/%m/%Y às %H:%M")
  end
  
  def can_retry?
    failed? || pending?
  end
end