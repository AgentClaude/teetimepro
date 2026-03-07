FactoryBot.define do
  factory :membership do
    organization
    user

    tier { :gold }
    status { :active }
    price_cents { 250_00 }
    starts_at { 1.year.ago }
    ends_at { 1.year.from_now }
    auto_renew { true }
    account_balance_cents { 0 }
    credit_limit_cents { 500_000 } # $5,000

    trait :basic do
      tier { :basic }
      price_cents { 100_00 }
    end

    trait :platinum do
      tier { :platinum }
      price_cents { 500_00 }
      credit_limit_cents { 1_000_000 }
    end

    trait :expired do
      status { :expired }
      starts_at { 2.years.ago }
      ends_at { 1.year.ago }
    end

    trait :with_balance do
      account_balance_cents { 150_00 }
    end

    trait :near_limit do
      account_balance_cents { 490_000 }
      credit_limit_cents { 500_000 }
    end
  end
end
