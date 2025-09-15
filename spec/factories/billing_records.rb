FactoryBot.define do
  factory :billing_record do
    customer
    month { Date.current.month }
    year { Date.current.year }
    processed_at { Time.current }
    status { :pending }
    amount { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    
    trait :successful do
      status { :success }
      transaction_id { "TXN_#{SecureRandom.hex(8)}" }
    end
    
    trait :failed do
      status { :failed }
      error_message { "Payment gateway timeout" }
    end
    
    trait :current_month do
      month { Date.current.month }
      year { Date.current.year }
      processed_at { Time.current }
    end
  end
end