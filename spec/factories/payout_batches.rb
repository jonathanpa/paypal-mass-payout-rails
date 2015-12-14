FactoryGirl.define do
  factory :payout_batch do
    email_subject 'You have a Payout !'
    currency { Currency.find_or_create_by(code: 'USD') }
  end
end

