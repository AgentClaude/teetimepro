FactoryBot.define do
  factory :loyalty_account do
    association :organization
    association :user
    points_balance { 100 }
    lifetime_points { 250 }
    tier { :bronze }

    trait :silver_tier do
      points_balance { 500 }
      lifetime_points { 750 }
      tier { :silver }
    end

    trait :gold_tier do
      points_balance { 1500 }
      lifetime_points { 2500 }
      tier { :gold }
    end

    trait :platinum_tier do
      points_balance { 3000 }
      lifetime_points { 6000 }
      tier { :platinum }
    end

    trait :zero_balance do
      points_balance { 0 }
      lifetime_points { 100 }
    end

    trait :high_balance do
      points_balance { 5000 }
      lifetime_points { 10000 }
    end
  end
end