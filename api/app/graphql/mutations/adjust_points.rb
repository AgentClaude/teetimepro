module Mutations
  class AdjustPoints < BaseMutation
    argument :user_id, ID, required: true
    argument :points_adjustment, Integer, required: true
    argument :reason, String, required: true

    field :account, Types::LoyaltyAccountType, null: true
    field :transaction, Types::LoyaltyTransactionType, null: true
    field :errors, [String], null: false

    def resolve(user_id:, points_adjustment:, reason:)
      organization = require_auth!
      require_role!(:manager)

      target_user = User.find(user_id)

      result = Loyalty::AdjustPointsService.call(
        user: target_user,
        organization: organization,
        points_adjustment: points_adjustment,
        reason: reason,
        admin_user: current_user
      )

      if result.success?
        {
          account: result.account,
          transaction: result.transaction,
          errors: []
        }
      else
        { account: nil, transaction: nil, errors: result.errors }
      end
    end
  end
end