module Types
  class MembershipType < BaseObject
    field :id, ID, null: false
    field :tier, String, null: false
    field :status, String, null: false
    field :price_cents, Integer, null: true
    field :starts_at, GraphQL::Types::ISO8601DateTime, null: false
    field :ends_at, GraphQL::Types::ISO8601DateTime, null: false
    field :auto_renew, Boolean, null: false
    field :days_remaining, Integer, null: false
    field :account_balance_cents, Integer, null: false
    field :credit_limit_cents, Integer, null: false
    field :available_credit_cents, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :user, Types::UserType, null: false
    field :organization, Types::OrganizationType, null: false
    field :recent_charges, [Types::MemberAccountChargeType], null: false

    def recent_charges
      object.member_account_charges.outstanding.recent.limit(10)
    end
  end
end
