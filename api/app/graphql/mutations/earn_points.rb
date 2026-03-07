module Mutations
  class EarnPoints < BaseMutation
    argument :user_id, ID, required: false
    argument :points, Integer, required: true
    argument :description, String, required: true
    argument :source_type, String, required: false
    argument :source_id, ID, required: false

    field :account, Types::LoyaltyAccountType, null: true
    field :transaction, Types::LoyaltyTransactionType, null: true
    field :errors, [String], null: false

    def resolve(points:, description:, user_id: nil, source_type: nil, source_id: nil)
      organization = require_auth!
      
      # If user_id is provided, require manager role, otherwise use current user
      target_user = if user_id
                      require_role!(:manager)
                      User.find(user_id)
                    else
                      current_user
                    end

      # Find source object if provided
      source = nil
      if source_type && source_id
        source_class = source_type.constantize
        source = source_class.find(source_id)
      end

      result = Loyalty::EarnPointsService.call(
        user: target_user,
        organization: organization,
        points: points,
        description: description,
        source: source
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