module Types
  class LoyaltyRedemptionType < Types::BaseObject
    field :id, ID, null: false
    field :status, String, null: false
    field :code, String, null: false
    field :expires_at, GraphQL::Types::ISO8601DateTime, null: true
    field :expired, Boolean, null: false
    field :can_be_applied, Boolean, null: false
    field :can_be_cancelled, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :loyalty_account, Types::LoyaltyAccountType, null: false
    field :loyalty_reward, Types::LoyaltyRewardType, null: false
    field :booking, Types::BookingType, null: true
    field :organization, Types::OrganizationType, null: false
    field :user, Types::UserType, null: false

    def expired
      object.expired?
    end

    def can_be_applied
      object.can_be_applied?
    end

    def can_be_cancelled
      object.can_be_cancelled?
    end

    def organization
      object.organization
    end

    def user
      object.user
    end
  end
end