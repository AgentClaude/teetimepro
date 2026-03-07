module Types
  class LoyaltyProgramType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: true
    field :points_per_dollar, Integer, null: false
    field :is_active, Boolean, null: false
    field :tier_thresholds, GraphQL::Types::JSON, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :organization, Types::OrganizationType, null: false

    def tier_thresholds
      object.tier_thresholds
    end
  end
end