module Mutations
  class CreateReward < BaseMutation
    argument :name, String, required: true
    argument :description, String, required: false
    argument :points_cost, Integer, required: true
    argument :reward_type, Types::LoyaltyRewardTypeEnum, required: true
    argument :discount_value, Integer, required: false
    argument :is_active, Boolean, required: false
    argument :max_redemptions_per_user, Integer, required: false

    field :reward, Types::LoyaltyRewardType, null: true
    field :errors, [String], null: false

    def resolve(name:, points_cost:, reward_type:, description: nil, discount_value: nil, 
                is_active: true, max_redemptions_per_user: nil)
      organization = require_auth!
      require_role!(:manager)

      result = Loyalty::CreateRewardService.call(
        organization: organization,
        name: name,
        description: description,
        points_cost: points_cost,
        reward_type: reward_type,
        discount_value: discount_value,
        is_active: is_active,
        max_redemptions_per_user: max_redemptions_per_user,
        admin_user: current_user
      )

      if result.success?
        { reward: result.reward, errors: [] }
      else
        { reward: nil, errors: result.errors }
      end
    end
  end
end