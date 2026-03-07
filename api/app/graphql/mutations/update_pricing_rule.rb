module Mutations
  class UpdatePricingRule < BaseMutation
    description "Update an existing pricing rule"

    argument :id, ID, required: true
    argument :name, String, required: false
    argument :rule_type, Types::PricingRuleTypeEnum, required: false
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

    def resolve(id:, **args)
      pricing_rule = current_organization.pricing_rules.find(id)

      result = ::Pricing::UpdateRuleService.call(
        pricing_rule: pricing_rule,
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
    rescue ActiveRecord::RecordNotFound
      {
        pricing_rule: nil,
        errors: ["Pricing rule not found"]
      }
    end
  end
end