module Payments
  class Base
    def charge(customer, amount)
      validate_inputs(customer, amount)
      raise NotImplementedError, "Subclass must implement #charge method"
    end

    def self.display_name
      name.demodulize.humanize
    end
    
    protected
    
    def generate_transaction_id(prefix)
      "#{prefix}_#{SecureRandom.hex(8).upcase}"
    end
    
    def log_payment(customer, amount, status, details = {})
      Rails.logger.info "[#{self.class.name}] Customer: #{customer.name} | Amount: R$ #{amount} | Status: #{status} | Details: #{details}"
    end

    def validate_inputs(customer, amount)
      if customer.blank?
        raise ArgumentError, "Customer cannot be blank"
      end
      
      unless customer.is_a?(Customer)
        raise ArgumentError, "Expected Customer object, got #{customer.class}"
      end
      
      if amount.blank? || amount <= 0
        raise ArgumentError, "Amount must be positive number, got #{amount}"
      end
    end
  end
end
