class Customer < ApplicationRecord
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, 
                   uniqueness: { case_sensitive: false },
                   format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :billing_day, presence: true, inclusion: { in: 1..31 }
  validates :payment_method_type, presence: true
  
  before_save :normalize_email
  
  has_many :billing_records, dependent: :destroy
  
  def effective_billing_day(date = Date.current)
    # Se billing_day > dias do mês, usa último dia do mês
    last_day_of_month = Date.new(date.year, date.month, -1).day
    [billing_day, last_day_of_month].min
  end
  
  private
  
  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
