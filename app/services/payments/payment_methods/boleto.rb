module Payments
  module PaymentMethods
    class Boleto < Payments::Base
      def charge(customer, amount)
        validate_inputs(customer, amount)
        log_payment(customer, amount, "PROCESSING", { method: "boleto" })
        
        transaction_id = generate_transaction_id("BOL")
        barcode = generate_barcode
        due_date = calculate_due_date
        
        generate_boleto(customer, amount, barcode, due_date)
        
        log_payment(customer, amount, "SUCCESS", { transaction_id: transaction_id })
        
        {
          status: :success,
          transaction_id: transaction_id,
          barcode: barcode,
          due_date: due_date,
          boleto_url: "https://banco.exemplo.com/boleto/#{transaction_id}"
        }
      end
      
      private
      
      def generate_barcode
        "#{rand(10000..99999)}.#{rand(10000..99999)} #{rand(10000..99999)}.#{rand(100000..999999)} #{rand(10000..99999)}.#{rand(100000..999999)} #{rand(1..9)} #{rand(10000000000000..99999999999999)}"
      end
      
      def calculate_due_date
        (Date.current + 3.days)
      end
      
      def generate_boleto(customer, amount, barcode, due_date)
        puts "📄 BOLETO GERADO - Cliente: #{customer.name} | Valor: R$ #{amount} | Vencimento: #{due_date.strftime('%d/%m/%Y')}"
      end
    end
  end
end
