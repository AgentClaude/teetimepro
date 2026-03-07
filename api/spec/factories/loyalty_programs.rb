FactoryBot.define do
  factory :loyalty_program do
    association :organization
    name { "TeeTime Pro Loyalty" }
    description { "Earn points for every booking and purchase!" }
    points_per_dollar { 10 }
    is_active { true }
    tier_thresholds { { "silver" => 500, "gold" => 2000, "platinum" => 5000 } }

    trait :inactive do
      is_active { false }
    end

    trait :with_custom_thresholds do
      tier_thresholds { { "silver" => 1000, "gold" => 3000, "platinum" => 7500 } }
    end

    trait :high_points_rate do
      points_per_dollar { 20 }
    end
  end
end