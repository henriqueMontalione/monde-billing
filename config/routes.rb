Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  root 'customers#index'
  resources :customers
end
