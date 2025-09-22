module Payments
  module PaymentMethods
    class Deposito < Payments::Base
      def charge(customer, amount)
        validate_inputs(customer, amount)

        transaction_id = generate_transaction_id("DEP")

        log_payment(customer, amount, "processado", {
          transaction_id: transaction_id,
          banco: "Banco do Brasil",
          agencia: "1234-5",
          conta: "67890-1"
        })

        puts "💰 DEPÓSITO PROCESSADO - Cliente: #{customer.name} | Valor: R$ #{amount} | ID: #{transaction_id}"

        {
          success: true,
          transaction_id: transaction_id,
          details: {
            payment_method: "Depósito Bancário",
            banco: "Banco do Brasil",
            agencia: "1234-5",
            conta: "67890-1",
            processed_at: Time.current
          }
        }
      rescue => e
        if customer
          log_payment(customer, amount, "erro", { error: e.message })
        end

        {
          success: false,
          error: e.message,
          details: {
            payment_method: "Depósito Bancário",
            failed_at: Time.current
          }
        }
      end

      def self.display_name
        "Depósito Bancário"
      end
    end
  end
end
