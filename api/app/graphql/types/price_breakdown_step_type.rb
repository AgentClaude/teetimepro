module Types
  class PriceBreakdownStepType < Types::BaseObject
    field :step, String, null: false
    field :description, String, null: false
    field :rule_type, Types::PricingRuleTypeEnum, null: true
    field :multiplier, Float, null: true
    field :flat_adjustment_cents, Int, null: true
    field :flat_adjustment, String, null: true do
      description "Formatted flat adjustment amount"
    end
    field :price_cents, Int, null: false
    field :price, String, null: false do
      description "Formatted price at this step"
    end
    field :adjustment_cents, Int, null: false
    field :adjustment, String, null: false do
      description "Formatted adjustment for this step"
    end

    def flat_adjustment
      return nil if object[:flat_adjustment_cents].nil?
      Money.new(object[:flat_adjustment_cents]).format
    end

    def price
      Money.new(object[:price_cents]).format
    end

    def adjustment
      Money.new(object[:adjustment_cents]).format
    end
  end
end