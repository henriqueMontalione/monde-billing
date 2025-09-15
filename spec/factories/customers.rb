FactoryBot.define do
  factory :customer do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    billing_day { rand(1..31) }
    payment_method_type { %w[boleto credit_card pix].sample }
    
    trait :with_boleto do
      payment_method_type { 'boleto' }
    end
    
    trait :billing_today do
      billing_day { Date.current.day }
    end
    
    trait :end_of_month do
      billing_day { 31 }
    end
  end
end
