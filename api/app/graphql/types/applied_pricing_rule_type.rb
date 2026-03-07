module Types
  class AppliedPricingRuleType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :rule_type, Types::PricingRuleTypeEnum, null: false
    field :multiplier, Float, null: false
    field :flat_adjustment_cents, Int, null: false
    field :flat_adjustment, String, null: false do
      description "Formatted flat adjustment amount"
    end
    field :priority, Int, null: false
    field :conditions, GraphQL::Types::JSON, null: false

    def flat_adjustment
      Money.new(object[:flat_adjustment_cents]).format
    end
  end
end