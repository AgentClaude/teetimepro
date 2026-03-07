module Mutations
  class CreateLoyaltyProgram < BaseMutation
    argument :name, String, required: true
    argument :description, String, required: false
    argument :points_per_dollar, Integer, required: false
    argument :tier_thresholds, GraphQL::Types::JSON, required: false
    argument :is_active, Boolean, required: false

    field :program, Types::LoyaltyProgramType, null: true
    field :errors, [String], null: false

    def resolve(name:, description: nil, points_per_dollar: 10, tier_thresholds: nil, is_active: true)
      organization = require_auth!
      require_role!(:manager)

      result = Loyalty::CreateProgramService.call(
        organization: organization,
        name: name,
        description: description,
        points_per_dollar: points_per_dollar,
        tier_thresholds: tier_thresholds,
        is_active: is_active
      )

      if result.success?
        { program: result.program, errors: [] }
      else
        { program: nil, errors: result.errors }
      end
    end
  end
end