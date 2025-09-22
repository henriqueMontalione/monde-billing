# Monde Billing System

Sistema de faturamento desenvolvido em Ruby on Rails com foco em simplicidade, qualidade de código e experiência do usuário.

## 📋 Sobre o Projeto

Este sistema foi desenvolvido como parte de um teste técnico, implementando um sistema de faturamento completo com gestão de clientes, múltiplos métodos de pagamento e automação de cobrança.

## 🚀 Tecnologias Utilizadas

- **Ruby**: 3.2.0
- **Rails**: 7.1.3
- **Database**: SQLite3 (desenvolvimento) / PostgreSQL (produção)
- **Frontend**: Hotwire (Turbo + Stimulus), Bootstrap 5.3
- **Background Jobs**: Sidekiq
- **Authentication**: Devise
- **Internationalization**: i18n (pt-BR)
- **Testing**: RSpec
- **Code Quality**: RuboCop

## 🏗️ Arquitetura e Design Patterns

### Strategy Pattern - Métodos de Pagamento

Implementei o Strategy Pattern para gerenciar diferentes métodos de pagamento de forma extensível:

```ruby
# app/services/payments/payment_methods/
├── base.rb              # Classe base em app/services/payments/base.rb
├── credit_card.rb       # Implementação para cartão de crédito
├── boleto.rb           # Implementação para boleto bancário
├── pix.rb              # Implementação para PIX
└── deposito.rb         # Implementação para depósito bancário
```

**Benefícios alcançados:**
- Fácil adição de novos métodos de pagamento
- Isolamento de responsabilidades
- Testabilidade individual de cada método
- Polimorfismo limpo e extensível

### Directory Scanning Pattern

Desenvolvi um sistema de scanning automático de diretórios para descoberta de payment methods:

```ruby
# config/initializers/payment_methods.rb
Dir[Rails.root.join('app/models/payment_methods/*.rb')].each { |f| require f }

PAYMENT_METHODS = PaymentMethods::Base.descendants.map do |klass|
  [klass.display_name, klass.name.demodulize.underscore]
end.freeze
```

**Vantagens obtidas:**
- Auto-descoberta de novos métodos
- Configuração centralizada
- Redução de manutenção manual

### Service Pattern - Processamento de Faturamento

Criei services para encapsular a lógica de negócio complexa:

```ruby
# app/services/billing_service.rb
class BillingService
  def self.process_monthly_billing
    # Lógica complexa de processamento
  end
end
```

### Background Jobs com Sidekiq

Processamento assíncrono para operações pesadas:

```ruby
# app/jobs/billing_job.rb
class BillingJob < ApplicationJob
  def perform
    BillingService.process_monthly_billing
  end
end
```

## 🎨 Decisões de UI/UX

### Hotwire + Turbo Streams

Optei por Hotwire para uma experiência SPA-like mantendo a simplicidade do Rails:

- **Turbo Drive**: Navegação rápida entre páginas
- **Turbo Frames**: Atualizações parciais de conteúdo
- **Turbo Streams**: Atualizações em tempo real
- **Stimulus**: JavaScript organizado e progressivo

### Bootstrap 5.3

Framework CSS escolhido pelos seguintes motivos:

- **Componentes prontos**: Reduz tempo de desenvolvimento
- **Responsividade**: Design mobile-first
- **Customização**: Fácil personalização via CSS variables
- **Acessibilidade**: Componentes acessíveis por padrão

### Internacionalização (i18n)

Sistema completamente localizado em português brasileiro:

```yaml
# config/locales/pt-BR.yml
pt-BR:
  activerecord:
    models:
      customer: "Cliente"
      billing_record: "Registro de Faturamento"
```

## 🎯 Soluções dos Requisitos Técnicos

### 1. Gestão de Clientes

**Implementação:**
- CRUD completo com validações robustas
- Interface responsiva com Hotwire
- Paginação com Kaminari
- Filtros e busca

**Decisões técnicas:**
- Validações no modelo e frontend
- Uso de partials para reutilização de código
- Turbo Streams para atualizações sem refresh

### 2. Múltiplos Métodos de Pagamento

**Implementação:**
- Strategy Pattern para extensibilidade
- Polimorfismo com `payment_method_type`
- Auto-descoberta de novos métodos
- Validações específicas por tipo

**Benefícios:**
- Fácil adição de novos métodos
- Código limpo e testável
- Configuração centralizada

### 3. Sistema de Faturamento

**Implementação:**
- Service objects para lógica complexa
- Background jobs para processamento assíncrono
- Modelo `BillingRecord` para histórico
- Idempotência para evitar duplicatas

**Decisões técnicas:**
- Separação clara entre modelos e services
- Jobs assíncronos para escalabilidade
- Auditoria completa de operações

### 4. Automação de Jobs

**Implementação:**
- Sidekiq para background processing
- Jobs recorrentes com sidekiq-scheduler
- Monitoramento via web UI
- Retry automático com backoff

**Configuração:**
```ruby
# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
end
```

## 🔧 Configuração e Execução

### Pré-requisitos

- Ruby 3.2.0
- Node.js 18+
- Redis (para Sidekiq)
- SQLite3

### Instalação

```bash
# Clone o repositório
git clone https://github.com/monde-testes/teste-ruby-carlos-montalione.git
cd teste-ruby-carlos-montalione

# Instale as dependências
bundle install
yarn install

# Configure o banco de dados
rails db:create db:migrate db:seed

# Inicie os serviços
rails server
bundle exec sidekiq
```

## 🧪 Testes

```bash
# Executar toda a suíte de testes
bundle exec rspec

# Testes com coverage
bundle exec rspec --format documentation
```

### Monitoramento

- **Logs estruturados**: JSON logging para produção
- **Sidekiq Web UI**: Monitoramento de jobs

### Padrões de Código

- **Style Guide**: Seguimos o Ruby Style Guide
- **Git Flow**: Feature branches + merge para main
- **Commit Messages**: Conventional commits
- **Code Review**: Obrigatório para mudanças em produção

### Estrutura de Branches

```
main                    # Branch principal
├── feature/new-feature # Novas funcionalidades
├── bugfix/fix-issue    # Correções de bugs
└── hotfix/urgent-fix   # Correções urgentes
```