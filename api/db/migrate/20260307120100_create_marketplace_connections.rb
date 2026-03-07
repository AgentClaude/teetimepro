class CreateMarketplaceConnections < ActiveRecord::Migration[8.0]
  def change
    create_table :marketplace_connections do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.string :provider, null: false # golfnow, teeoff
      t.integer :status, null: false, default: 0 # pending, active, paused, error
      t.string :external_course_id # ID on the marketplace platform
      t.jsonb :credentials, null: false, default: {} # encrypted API keys/tokens
      t.jsonb :settings, null: false, default: {} # syndication rules
      t.datetime :last_synced_at
      t.string :last_error
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index [:organization_id, :course_id, :provider], unique: true,
              name: "idx_marketplace_connections_org_course_provider"
      t.index [:provider, :status]
    end

    create_table :marketplace_listings do |t|
      t.references :marketplace_connection, null: false, foreign_key: true
      t.references :tee_time, null: false, foreign_key: true
      t.string :external_listing_id # ID on the marketplace
      t.integer :status, null: false, default: 0 # pending, listed, booked, expired, error
      t.integer :listed_price_cents
      t.string :listed_price_currency, default: "USD"
      t.integer :commission_rate_bps # basis points (e.g., 1500 = 15%)
      t.datetime :listed_at
      t.datetime :expires_at
      t.jsonb :metadata, null: false, default: {}
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index [:marketplace_connection_id, :tee_time_id], unique: true,
              name: "idx_marketplace_listings_connection_tee_time"
      t.index [:external_listing_id], name: "idx_marketplace_listings_external_id"
      t.index [:status]
    end
  end
end
