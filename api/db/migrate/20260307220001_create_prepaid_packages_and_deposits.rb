class CreatePrepaidPackagesAndDeposits < ActiveRecord::Migration[8.0]
  def change
    create_table :prepaid_packages do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.references :course, null: true, foreign_key: { on_delete: :nullify }
      t.string :name, null: false
      t.text :description
      t.integer :package_type, default: 0, null: false # round_pack, time_pass, value_card
      t.integer :rounds_included # for round_pack type
      t.integer :price_cents, null: false
      t.string :price_currency, default: "USD", null: false
      t.integer :value_cents # for value_card type (loaded amount)
      t.string :value_currency, default: "USD", null: false
      t.integer :validity_days # nil = never expires
      t.integer :max_players_per_round, default: 4
      t.boolean :transferable, default: false, null: false
      t.boolean :active, default: true, null: false
      t.jsonb :restrictions, default: {} # day_of_week, time_ranges, excluded_dates
      t.datetime :available_from
      t.datetime :available_until
      t.timestamps
    end

    create_table :prepaid_purchases do |t|
      t.references :prepaid_package, null: false, foreign_key: { on_delete: :restrict }
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :payment, null: true, foreign_key: { on_delete: :nullify }
      t.string :code, null: false # unique redemption code
      t.integer :status, default: 0, null: false # active, expired, fully_redeemed, cancelled, suspended
      t.integer :rounds_remaining # for round_pack
      t.integer :balance_cents # for value_card
      t.string :balance_currency, default: "USD", null: false
      t.datetime :purchased_at, null: false
      t.datetime :expires_at
      t.datetime :activated_at
      t.jsonb :metadata, default: {}
      t.timestamps
    end

    create_table :prepaid_redemptions do |t|
      t.references :prepaid_purchase, null: false, foreign_key: { on_delete: :cascade }
      t.references :booking, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.integer :redemption_type, default: 0, null: false # round, value
      t.integer :rounds_used, default: 1
      t.integer :value_cents # for value_card redemptions
      t.string :value_currency, default: "USD", null: false
      t.timestamps
    end

    # Deposit tracking on bookings
    add_column :bookings, :deposit_cents, :integer
    add_column :bookings, :deposit_currency, :string, default: "USD"
    add_column :bookings, :deposit_paid_at, :datetime
    add_column :bookings, :deposit_required, :boolean, default: false, null: false

    add_index :prepaid_packages, [:organization_id, :active], name: "idx_prepaid_packages_org_active"
    add_index :prepaid_purchases, :code, unique: true
    add_index :prepaid_purchases, [:user_id, :status], name: "idx_prepaid_purchases_user_status"
    add_index :prepaid_purchases, :expires_at
    add_index :prepaid_redemptions, [:prepaid_purchase_id, :booking_id], unique: true, name: "idx_prepaid_redemptions_purchase_booking"
  end
end
