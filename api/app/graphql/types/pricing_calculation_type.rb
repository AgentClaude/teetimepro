module Types
  class PricingCalculationType < Types::BaseObject
    field :original_price_cents, Int, null: false
    field :original_price, String, null: false do
      description "Formatted original price"
    end
    field :dynamic_price_cents, Int, null: false
    field :dynamic_price, String, null: false do
      description "Formatted dynamic price"
    end
    field :price_adjustment_cents, Int, null: false
    field :price_adjustment, String, null: false do
      description "Formatted price adjustment"
    end
    field :applied_rules, [Types::AppliedPricingRuleType], null: false
    field :price_breakdown, [Types::PriceBreakdownStepType], null: false

    def original_price
      Money.new(object[:original_price_cents]).format
    end

    def dynamic_price
      Money.new(object[:dynamic_price_cents]).format
    end

    def price_adjustment
      Money.new(object[:price_adjustment_cents]).format
    end
  end
end