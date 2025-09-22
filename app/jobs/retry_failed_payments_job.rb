class RetryFailedPaymentsJob < ApplicationJob
  queue_as :retries

  MAX_RETRY_ATTEMPTS = 3
  RETRY_DELAYS = [2.hours, 6.hours, 24.hours].freeze

  def perform(date = Date.current)
    Rails.logger.info "🔄 Iniciando retry de pagamentos falhados para #{date.strftime('%d/%m/%Y')}"

    failed_records = BillingRecord.joins(:customer)
                                  .where(
                                    status: 'failed',
                                    billing_date: date,
                                    retry_count: 0...MAX_RETRY_ATTEMPTS
                                  )

    if failed_records.empty?
      Rails.logger.info "ℹ️  Nenhum pagamento para retry encontrado"
      return
    end

    retry_count = 0
    success_count = 0

    failed_records.each do |record|
      Rails.logger.info "🔄 Tentando novamente: Cliente #{record.customer.name} - Tentativa #{record.retry_count + 1}"

      begin
        record.increment!(:retry_count)
        payment_result = process_retry_payment(record)

        if payment_result[:success]
          record.update!(
            status: 'completed',
            payment_details: payment_result[:details]
          )
          success_count += 1
          Rails.logger.info "✅ Retry bem-sucedido para #{record.customer.name}"
        else
          handle_retry_failure(record, payment_result[:error])
        end

        retry_count += 1
      rescue => e
        Rails.logger.error "💥 Erro no retry para #{record.customer.name}: #{e.message}"
        handle_retry_failure(record, e.message)
      end
    end

    Rails.logger.info "🔄 Retry concluído: #{success_count}/#{retry_count} sucessos"
  end

  private

  def process_retry_payment(record)
    customer = record.customer
    payment_method = Payments::PaymentService.get_payment_method(customer.payment_method_type)

    result = payment_method.process_payment(
      customer: customer,
      amount: record.amount
    )

    {
      success: result[:success],
      details: result[:details],
      error: result[:error]
    }
  rescue => e
    {
      success: false,
      error: e.message
    }
  end

  def handle_retry_failure(record, error_message)
    if record.retry_count >= MAX_RETRY_ATTEMPTS
      Rails.logger.error "❌ Máximo de tentativas atingido para #{record.customer.name}"
      record.update!(
        status: 'permanently_failed',
        error_details: "Max retries exceeded: #{error_message}"
      )
    else
      Rails.logger.warn "⚠️  Retry falhado para #{record.customer.name}: #{error_message}"
      record.update!(error_details: error_message)

      next_delay = RETRY_DELAYS[record.retry_count - 1] || 24.hours
      RetryFailedPaymentsJob.set(wait: next_delay).perform_later(record.billing_date)
    end
  end
end