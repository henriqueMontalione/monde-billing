module Billing
  class BillingService
    class BillingError < StandardError; end

    class << self
      def process_billing_for_date(date = Date.current)
        customers = customers_to_bill_on_date(date)
        results = { success: [], failed: [], skipped: [] }

        customers.each do |customer|
          result = process_customer_billing(customer, date)
          results[result[:status]] << { customer: customer, details: result }
        end

        log_batch_summary(results, date)
        results
      end

      def process_customer_billing(customer, date = Date.current)
        raise ArgumentError, "Customer inválido" unless customer.is_a?(Customer)

        billing_record = create_billing_record(customer, date.month, date.year)
        process_payment(billing_record)
      rescue ActiveRecord::RecordInvalid => error
        if error.record.errors.of_kind?(:month, :taken)
          return { status: :skipped, message: "Cliente já faturado para #{date.month}/#{date.year}" }
        end
        update_billing_failure(billing_record, error) if billing_record&.persisted?
      rescue ActiveRecord::RecordNotUnique
        { status: :skipped, message: "Cliente já faturado para #{date.month}/#{date.year}" }
      rescue => error
        update_billing_failure(billing_record, error) if billing_record&.persisted?
      end

      def retry_billing(billing_record)
        raise BillingError, "Billing record cannot be retried (status: #{billing_record.status})" unless billing_record&.can_retry?

        billing_record.update!(status: :processing)

        begin
          process_payment(billing_record)
        rescue => error
          update_billing_failure(billing_record, error)
        end
      end

      private

      def process_payment(billing_record)
        payment_result = Payments::PaymentService.process_payment(billing_record.customer, billing_record.amount)

        billing_record.update!(
          status: :success,
          transaction_id: payment_result[:transaction_id],
          processed_at: payment_result[:charged_at] || Time.current
        )

        { status: :success, billing_record: billing_record, payment_result: payment_result }
      end

      def customers_to_bill_on_date(date)
        target_day = date.day
        month, year = date.month, date.year

        billing_days = [target_day]
        billing_days += (28..31).to_a if target_day >= 28

        Customer.where(billing_day: billing_days)
                .where.not(id: BillingRecord.where(month: month, year: year).select(:customer_id))
      end

      def create_billing_record(customer, month, year)
        BillingRecord.create!(
          customer: customer,
          month: month,
          year: year,
          processed_at: Time.current,
          status: :processing,
          amount: 99.90
        )
      end

      def update_billing_failure(billing_record, error)
        billing_record.update!(status: :failed, error_message: error.message)
        { status: :failed, billing_record: billing_record, error: error }
      end

      def log_batch_summary(results, date)
        total = results.values.sum(&:count)
        success = results[:success].count
        failed = results[:failed].count

        Rails.logger.info "[BillingService] #{date.strftime('%d/%m/%Y')} - Total: #{total} | Sucesso: #{success} | Falhas: #{failed}"
      end
    end
  end
end
