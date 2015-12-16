FactoryGirl.define do
  factory :payout_batch do
    email_subject 'You have a Payout !'
    currency { Currency.find_or_create_by(code: 'USD') }

    trait :pending do
      status 'PENDING'
      sequence(:paypal_id) { |n| "AAAA#{n}" }
    end

    factory :payout_batch_with_items do
      transient do
        items_count 2
      end

      after(:create) do |batch, evaluator|
        create_list(:payout_item,
                    evaluator.items_count,
                    currency: batch.currency,
                    payout_batch: batch)
      end
    end
  end
end

