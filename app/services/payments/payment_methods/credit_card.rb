module Payments
  module PaymentMethods
    class CreditCard < Payments::Base
      def charge(customer, amount)
        validate_inputs(customer, amount)
        log_payment(customer, amount, "PROCESSING", { method: "credit_card" })
        
        transaction_id = generate_transaction_id("CC")
        auth_code = generate_authorization_code
        
        puts "💳 CARTÃO DEBITADO - Cliente: #{customer.name} | Valor: R$ #{amount} | Auth: #{auth_code}"
        
        log_payment(customer, amount, "SUCCESS", { transaction_id: transaction_id })
        
        {
          status: :success,
          transaction_id: transaction_id,
          authorization_code: auth_code,
          charged_at: Time.current
        }
      end
      
      private
      
      def generate_authorization_code
        "AUTH_#{SecureRandom.hex(6).upcase}"
      end
    end
  end
end
