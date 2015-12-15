FactoryGirl.define do
  factory :payee do
    sequence(:email) { |n| "user_#{n}@email.com" }
    balance 20
    currency { Currency.find_or_create_by(code: 'USD') }
  end
end
