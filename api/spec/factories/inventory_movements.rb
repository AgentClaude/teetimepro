FactoryBot.define do
  factory :inventory_movement do
    association :organization
    association :pos_product
    association :course
    association :performed_by, factory: :user
    
    movement_type { 'adjustment' }
    quantity { 10 }
    notes { 'Test inventory movement' }
    unit_cost_cents { 250 }
    total_cost_cents { |movement| movement.unit_cost_cents ? movement.unit_cost_cents * movement.quantity.abs : nil }

    trait :receipt do
      movement_type { 'receipt' }
      quantity { 10 }
      unit_cost_cents { 250 }
    end

    trait :sale do
      movement_type { 'sale' }
      quantity { -5 }
      unit_cost_cents { nil }
    end

    trait :adjustment_positive do
      movement_type { 'adjustment' }
      quantity { 3 }
      notes { 'Stock adjustment - count correction' }
    end

    trait :adjustment_negative do
      movement_type { 'adjustment' }
      quantity { -2 }
      notes { 'Stock adjustment - damaged goods' }
    end

    trait :transfer_in do
      movement_type { 'transfer_in' }
      quantity { 5 }
      notes { 'Transfer from main warehouse' }
    end

    trait :transfer_out do
      movement_type { 'transfer_out' }
      quantity { -7 }
      notes { 'Transfer to pro shop' }
    end

    trait :with_reference do
      reference_type { 'Booking' }
      reference_id { '123' }
    end
  end
end