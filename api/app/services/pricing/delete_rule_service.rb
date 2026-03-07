module Pricing
  class DeleteRuleService < ApplicationService
    attr_accessor :pricing_rule, :user

    validates :pricing_rule, :user, presence: true

    def call
      return validation_failure(self) unless valid?

      authorize_user!

      if pricing_rule.destroy
        success(message: "Pricing rule '#{pricing_rule.name}' deleted successfully")
      else
        validation_failure(pricing_rule)
      end
    rescue AuthorizationError => e
      failure([e.message])
    rescue => e
      failure(["Error deleting pricing rule: #{e.message}"])
    end

    private

    def authorize_user!
      authorize_org_access!(user, pricing_rule.organization)
      authorize_role!(user, :admin)
    end
  end
end