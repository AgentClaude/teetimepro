module Mutations
  class CreatePricingRule < BaseMutation
    description "Create a new pricing rule"

    argument :name, String, required: true
    argument :rule_type, Types::PricingRuleTypeEnum, required: true
    argument :course_id, ID, required: false
    argument :conditions, GraphQL::Types::JSON, required: false
    argument :multiplier, Float, required: false
    argument :flat_adjustment_cents, Int, required: false
    argument :priority, Int, required: false
    argument :active, Boolean, required: false
    argument :start_date, GraphQL::Types::ISO8601Date, required: false
    argument :end_date, GraphQL::Types::ISO8601Date, required: false

    field :pricing_rule, Types::PricingRuleType, null: true
    field :errors, [String], null: false

    def resolve(**args)
      result = ::Pricing::CreateRuleService.call(
        organization: current_organization,
        user: current_user,
        **args
      )

      if result.success?
        { 
          pricing_rule: result.pricing_rule,
          errors: []
        }
      else
        {
          pricing_rule: nil,
          errors: result.errors
        }
      end
    end
  end
end