FactoryBot.define do
  factory :fnb_tab_item do
    fnb_tab
    added_by { association :user, organization: fnb_tab.organization }
    name { Faker::Food.dish }
    quantity { rand(1..3) }
    unit_price_cents { rand(500..2000) }
    category { 'food' }
    notes { nil }

    # total_cents is calculated automatically via before_validation

    trait :beverage do
      name { Faker::Food.ingredient }
      category { 'beverage' }
      unit_price_cents { rand(200..800) }
    end

    trait :other do
      name { 'Service Charge' }
      category { 'other' }
      unit_price_cents { 500 }
    end

    trait :with_notes do
      notes { 'Extra spicy' }
    end

    trait :expensive do
      unit_price_cents { rand(3000..5000) }
    end
  end
end