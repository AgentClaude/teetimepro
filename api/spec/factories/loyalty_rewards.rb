FactoryBot.define do
  factory :loyalty_reward do
    association :organization
    name { "10% Discount" }
    description { "Get 10% off your next round" }
    points_cost { 500 }
    reward_type { :discount_percentage }
    discount_value { 10 }
    is_active { true }
    max_redemptions_per_user { nil }

    trait :fixed_discount do
      name { "$20 Off" }
      description { "$20 off your next booking" }
      reward_type { :discount_fixed }
      discount_value { 2000 } # $20 in cents
      points_cost { 1000 }
    end

    trait :free_round do
      name { "Free Round" }
      description { "Free 18-hole round of golf" }
      reward_type { :free_round }
      discount_value { nil }
      points_cost { 2500 }
    end

    trait :pro_shop_credit do
      name { "$50 Pro Shop Credit" }
      description { "$50 to spend at the pro shop" }
      reward_type { :pro_shop_credit }
      discount_value { 5000 } # $50 in cents
      points_cost { 2000 }
    end

    trait :inactive do
      is_active { false }
    end

    trait :limited_redemptions do
      max_redemptions_per_user { 2 }
    end

    trait :high_cost do
      points_cost { 5000 }
    end

    trait :low_cost do
      points_cost { 100 }
    end
  end
end