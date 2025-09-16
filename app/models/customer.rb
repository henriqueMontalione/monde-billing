class Customer < ApplicationRecord
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, 
                   uniqueness: { case_sensitive: false },
                   format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :billing_day, presence: true, inclusion: { in: 1..31 }
  validates :payment_method_type, presence: true
  
  before_save :normalize_email
  
  has_many :billing_records, dependent: :destroy

  validate :validate_payment_method_exists
  
  def effective_billing_day(date = Date.current)
    # Se billing_day > dias do mês, usa último dia do mês
    last_day_of_month = Date.new(date.year, date.month, -1).day
    [billing_day, last_day_of_month].min
  end
  
  private
  
  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def validate_payment_method_exists
    return unless payment_method_type.present?
    
    unless Payments::PaymentService.method_exists?(payment_method_type)
      errors.add(:payment_method_type, "não é um método válido")
    end
  rescue => e
    Rails.logger.warn "Payment methods não disponíveis para validação: #{e.message}"
  end
end
