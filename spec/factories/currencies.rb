FactoryGirl.define do
  factory :currency, aliases: [:usd] do
    code 'USD'
  end

  factory :eur, class: Currency do
    code 'EUR'
  end

  factory :gbp, class: Currency do
    code 'GBP'
  end
end
