module Mutations
  class RedeemReward < BaseMutation
    argument :reward_id, ID, required: true

    field :redemption, Types::LoyaltyRedemptionType, null: true
    field :account, Types::LoyaltyAccountType, null: true
    field :errors, [String], null: false

    def resolve(reward_id:)
      organization = require_auth!

      result = Loyalty::RedeemRewardService.call(
        user: current_user,
        organization: organization,
        reward_id: reward_id
      )

      if result.success?
        {
          redemption: result.redemption,
          account: result.account,
          errors: []
        }
      else
        { redemption: nil, account: nil, errors: result.errors }
      end
    end
  end
end