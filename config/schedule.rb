# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Set the Rails environment for all jobs
env :PATH, ENV['PATH']
set :environment, Rails.env
set :output, "#{Rails.root}/log/cron.log"

# ==========================================
# BILLING AUTOMATION JOBS
# ==========================================

# Billing job - executa todo dia às 9h da manhã
# Este é o job principal que processa todas as cobranças do dia
every 1.day, at: '9:00 am' do
  runner "BillingJob.perform_later"
end

# ==========================================
# MAINTENANCE JOBS
# ==========================================

# Cleanup job - remove logs antigos e dados temporários
# Executa todo domingo às 2h da manhã
every :sunday, at: '2:00 am' do
  runner "Rails.logger.info('🧹 Executando limpeza semanal...')"
end

# ==========================================
# DEVELOPMENT/TESTING
# ==========================================

# Para desenvolvimento/teste, descomente a linha abaixo:
# every 1.minute do
#   runner "BillingJob.perform_later"
# end

# Para deploy em produção, execute:
# bundle exec whenever --update-crontab
#
# Para ver as tarefas agendadas:
# bundle exec whenever
#
# Learn more: http://github.com/javan/whenever