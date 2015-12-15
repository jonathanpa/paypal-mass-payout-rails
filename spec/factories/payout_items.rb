FactoryGirl.define do
  factory :payout_item do
    amount 1.0
    currency { Currency.find_or_create_by(code: 'USD') }
    payout_batch
    payee
  end
end

