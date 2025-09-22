class BillingJob < ApplicationJob
  queue_as :billing

  def perform(date = Date.current)
    Rails.logger.info "🏦 Iniciando processo de faturamento para #{date.strftime('%d/%m/%Y')}"

    results = Billing::BillingService.process_billing_for_date(date)

    Rails.logger.info "✅ Faturamento concluído para #{date.strftime('%d/%m/%Y')}:"
    Rails.logger.info "   📊 Sucessos: #{results[:success].count}"
    Rails.logger.info "   ❌ Falhas: #{results[:failed].count}"
    Rails.logger.info "   ⏭️  Ignorados: #{results[:skipped].count}"

    if results[:failed].any?
      Rails.logger.info "⚠️  Agendando retry para pagamentos que falharam..."
      RetryFailedPaymentsJob.set(wait: 2.hours).perform_later(date)
    end

    results
  rescue => e
    Rails.logger.error "💥 Erro no BillingJob: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
end