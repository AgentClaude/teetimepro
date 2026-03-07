module Types
  class LoyaltyAccountType < Types::BaseObject
    field :id, ID, null: false
    field :points_balance, Integer, null: false
    field :lifetime_points, Integer, null: false
    field :tier, String, null: false
    field :tier_name, String, null: false
    field :points_needed_for_next_tier, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :organization, Types::OrganizationType, null: false
    field :user, Types::UserType, null: false
    field :loyalty_program, Types::LoyaltyProgramType, null: true
    field :recent_transactions, [Types::LoyaltyTransactionType], null: false

    def tier_name
      object.tier_name
    end

    def points_needed_for_next_tier
      object.points_needed_for_next_tier
    end

    def recent_transactions
      object.recent_transactions(limit: 10)
    end
  end
end