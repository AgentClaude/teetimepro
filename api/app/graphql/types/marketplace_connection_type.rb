module Types
  class MarketplaceConnectionType < Types::BaseObject
    field :id, ID, null: false
    field :provider, MarketplaceProviderEnum, null: false
    field :provider_label, String, null: false
    field :status, MarketplaceConnectionStatusEnum, null: false
    field :external_course_id, String, null: true
    field :settings, GraphQL::Types::JSON, null: false
    field :last_synced_at, GraphQL::Types::ISO8601DateTime, null: true
    field :last_error, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :course, Types::CourseType, null: false
    field :active_listings_count, Integer, null: false
    field :total_listings_count, Integer, null: false
    field :effective_settings, GraphQL::Types::JSON, null: false

    def active_listings_count
      object.marketplace_listings.active_listings.count
    end

    def total_listings_count
      object.marketplace_listings.count
    end
  end
end
