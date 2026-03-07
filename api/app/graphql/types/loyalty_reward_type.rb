module Types
  class LoyaltyRewardType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: true
    field :points_cost, Integer, null: false
    field :reward_type, String, null: false
    field :discount_value, Integer, null: true
    field :discount_display, String, null: false
    field :is_active, Boolean, null: false
    field :max_redemptions_per_user, Integer, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :organization, Types::OrganizationType, null: false
    field :can_be_redeemed, Boolean, null: false
    field :remaining_redemptions, Integer, null: true

    def discount_display
      object.discount_display
    end

    def can_be_redeemed
      return false unless context[:current_user]
      object.can_be_redeemed_by?(context[:current_user])
    end

    def remaining_redemptions
      return nil unless context[:current_user]
      object.remaining_redemptions_for(context[:current_user])
    end
  end
end