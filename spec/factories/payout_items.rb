FactoryGirl.define do
  factory :payout_item do
    payout_batch
    currency { Currency.find_or_create_by(code: 'USD') }
    payee
  end
end

