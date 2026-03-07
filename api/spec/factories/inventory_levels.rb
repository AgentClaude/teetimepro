FactoryBot.define do
  factory :inventory_level do
    association :organization
    association :pos_product
    association :course
    
    current_stock { 10 }
    reserved_stock { 0 }
    reorder_point { 5 }
    reorder_quantity { 20 }
    average_cost_cents { 250 }
    last_cost_cents { 275 }
    last_counted_at { 1.week.ago }
    association :last_counted_by, factory: :user

    trait :low_stock do
      current_stock { 3 }
      reorder_point { 5 }
    end

    trait :out_of_stock do
      current_stock { 0 }
      reorder_point { 5 }
    end

    trait :high_stock do
      current_stock { 100 }
      reorder_point { 10 }
    end

    trait :with_reservations do
      current_stock { 15 }
      reserved_stock { 5 }
    end

    trait :no_cost_info do
      average_cost_cents { nil }
      last_cost_cents { nil }
    end

    trait :recently_counted do
      last_counted_at { 1.hour.ago }
    end

    trait :never_counted do
      last_counted_at { nil }
      last_counted_by { nil }
    end
  end
end