module Mutations
  class DeletePricingRule < BaseMutation
    description "Delete a pricing rule"

    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :message, String, null: true
    field :errors, [String], null: false

    def resolve(id:)
      pricing_rule = current_organization.pricing_rules.find(id)

      result = ::Pricing::DeleteRuleService.call(
        pricing_rule: pricing_rule,
        user: current_user
      )

      if result.success?
        { 
          success: true,
          message: result.data[:message],
          errors: []
        }
      else
        {
          success: false,
          message: nil,
          errors: result.errors
        }
      end
    rescue ActiveRecord::RecordNotFound
      {
        success: false,
        message: nil,
        errors: ["Pricing rule not found"]
      }
    end
  end
end