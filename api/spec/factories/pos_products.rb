FactoryBot.define do
  factory :pos_product do
    organization
    course
    name { Faker::Commerce.product_name }
    sequence(:sku) { |n| "SKU-#{n.to_s.rjust(6, '0')}" }
    barcode { Faker::Barcode.ean(8) }
    price_cents { rand(100..10_000) }
    category { %w[food beverage apparel equipment rental other].sample }
    active { true }
    track_inventory { false }
    stock_quantity { nil }

    trait :food do
      category { 'food' }
      name { Faker::Food.dish }
    end

    trait :beverage do
      category { 'beverage' }
      name { Faker::Beer.name }
    end

    trait :apparel do
      category { 'apparel' }
      name { "#{Faker::Color.color_name.titleize} Golf Polo" }
    end

    trait :equipment do
      category { 'equipment' }
      name { "#{Faker::Commerce.product_name} Golf Club" }
    end

    trait :with_inventory do
      track_inventory { true }
      stock_quantity { rand(1..100) }
    end

    trait :out_of_stock do
      track_inventory { true }
      stock_quantity { 0 }
    end

    trait :inactive do
      active { false }
    end

    trait :without_barcode do
      barcode { nil }
    end
  end
end
