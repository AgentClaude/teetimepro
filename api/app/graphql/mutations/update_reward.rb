module Mutations
  class UpdateReward < BaseMutation
    argument :reward_id, ID, required: true
    argument :name, String, required: false
    argument :description, String, required: false
    argument :points_cost, Integer, required: false
    argument :reward_type, Types::LoyaltyRewardTypeEnum, required: false
    argument :discount_value, Integer, required: false
    argument :is_active, Boolean, required: false
    argument :max_redemptions_per_user, Integer, required: false

    field :reward, Types::LoyaltyRewardType, null: true
    field :errors, [String], null: false

    def resolve(reward_id:, **args)
      organization = require_auth!
      require_role!(:manager)

      begin
        reward = organization.loyalty_rewards.find(reward_id)
        
        if reward.update(args.compact)
          { reward: reward, errors: [] }
        else
          { reward: nil, errors: reward.errors.full_messages }
        end
      rescue ActiveRecord::RecordNotFound
        { reward: nil, errors: ["Reward not found"] }
      rescue => e
        { reward: nil, errors: ["Failed to update reward: #{e.message}"] }
      end
    end
  end
end