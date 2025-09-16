module Payments
  class PaymentService
    class << self
      # Directory Scanning - coração do sistema
      def available_methods
        @available_methods ||= discover_payment_methods
      end

      def find_method(type)
        available_methods[type.to_s]&.new
      end

      def options_for_select
        available_methods.map do |key, klass|
          [klass.display_name, key]
        end.sort_by(&:first)
      end

      def method_exists?(type)
        available_methods.key?(type.to_s)
      end

      def process_payment(customer, amount)
        payment_method = find_method(customer.payment_method_type)
        
        unless payment_method
          raise Payments::PaymentError, "Payment method not found: #{customer.payment_method_type}"
        end
        
        payment_method.charge(customer, amount)
      end
      
      private
      
      def discover_payment_methods
        methods = {}
        
        payment_methods_paths.each do |file_path|
          file_name = File.basename(file_path, '.rb')
          
          begin
            class_name = "Payments::PaymentMethods::#{file_name.camelize}"
            klass = class_name.constantize
            
            if klass < Payments::Base
              methods[file_name] = klass
            end
          rescue => e
            Rails.logger.error "Error loading payment method #{file_name}: #{e.message}"
          end
        end
        
        methods
      end

      def payment_methods_paths
        Dir[Rails.root.join('app/services/payments/payment_methods/*.rb')]
      end
    end
  end
end
