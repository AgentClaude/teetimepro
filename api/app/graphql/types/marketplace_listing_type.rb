module Types
  class MarketplaceListingType < Types::BaseObject
    field :id, ID, null: false
    field :status, MarketplaceListingStatusEnum, null: false
    field :external_listing_id, String, null: true
    field :listed_price_cents, Integer, null: true
    field :listed_price_currency, String, null: false
    field :commission_rate_bps, Integer, null: true
    field :listed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :expires_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :tee_time, Types::TeeTimeType, null: false
    field :marketplace_connection, Types::MarketplaceConnectionType, null: false
    field :commission_rate_percent, Float, null: false
    field :estimated_commission_cents, Integer, null: false
    field :net_revenue_cents, Integer, null: false
    field :provider_label, String, null: false
  end
end
