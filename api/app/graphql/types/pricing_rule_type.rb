module Types
  class PricingRuleType < Types::BaseObject
    field :id, ID, null: false
    field :organization_id, ID, null: false
    field :course_id, ID, null: true
    field :course, Types::CourseType, null: true
    field :name, String, null: false
    field :rule_type, Types::PricingRuleTypeEnum, null: false
    field :conditions, GraphQL::Types::JSON, null: false
    field :multiplier, Float, null: false
    field :flat_adjustment_cents, Int, null: false
    field :flat_adjustment, String, null: false do
      description "Formatted flat adjustment amount"
    end
    field :priority, Int, null: false
    field :active, Boolean, null: false
    field :start_date, GraphQL::Types::ISO8601Date, null: true
    field :end_date, GraphQL::Types::ISO8601Date, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def flat_adjustment
      Money.new(object.flat_adjustment_cents).format
    end
  end
end