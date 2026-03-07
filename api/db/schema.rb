# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_03_07_160002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.string "key_digest", null: false
    t.string "prefix", limit: 8, null: false
    t.jsonb "scopes", default: ["read"], null: false
    t.string "rate_limit_tier", default: "standard", null: false
    t.boolean "active", default: true, null: false
    t.datetime "expires_at", precision: nil
    t.datetime "last_used_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key_digest"], name: "index_api_keys_on_key_digest", unique: true
    t.index ["organization_id", "active"], name: "index_api_keys_on_organization_id_and_active"
    t.index ["organization_id"], name: "index_api_keys_on_organization_id"
    t.index ["prefix"], name: "index_api_keys_on_prefix"
    t.index ["rate_limit_tier"], name: "index_api_keys_on_rate_limit_tier"
    t.index ["scopes"], name: "index_api_keys_on_scopes", using: :gin
  end

  create_table "booking_players", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.bigint "golfer_profile_id"
    t.string "name"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_booking_players_on_booking_id"
    t.index ["golfer_profile_id"], name: "index_booking_players_on_golfer_profile_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "tee_time_id", null: false
    t.bigint "user_id", null: false
    t.string "confirmation_code", null: false
    t.integer "players_count", default: 1, null: false
    t.integer "total_cents"
    t.string "total_currency", default: "USD"
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "checked_in_at"
    t.datetime "cancelled_at"
    t.text "cancellation_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_code"], name: "index_bookings_on_confirmation_code", unique: true
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["tee_time_id"], name: "index_bookings_on_tee_time_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "courses", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.integer "holes", default: 18, null: false
    t.integer "interval_minutes", default: 8, null: false
    t.time "first_tee_time"
    t.time "last_tee_time"
    t.integer "max_players_per_slot", default: 4, null: false
    t.integer "weekday_rate_cents"
    t.integer "weekend_rate_cents"
    t.integer "twilight_rate_cents"
    t.string "weekday_rate_currency", default: "USD"
    t.string "weekend_rate_currency", default: "USD"
    t.string "twilight_rate_currency", default: "USD"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "phone"
    t.string "website"
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.string "timezone", default: "UTC"
    t.jsonb "settings", default: {}
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "voice_config", default: {}, null: false
    t.string "slug", null: false
    t.index ["active"], name: "index_courses_on_active"
    t.index ["organization_id", "name"], name: "index_courses_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_courses_on_organization_id"
    t.index ["slug"], name: "index_courses_on_slug", unique: true
  end

  create_table "email_campaigns", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "created_by_id", null: false
    t.string "name", null: false
    t.string "subject", null: false
    t.text "body_html", null: false
    t.text "body_text"
    t.integer "status", default: 0, null: false
    t.string "recipient_filter", default: "all", null: false
    t.jsonb "filter_criteria", default: {}, null: false
    t.integer "lapsed_days", default: 30, null: false
    t.integer "total_recipients", default: 0, null: false
    t.integer "sent_count", default: 0, null: false
    t.integer "delivered_count", default: 0, null: false
    t.integer "opened_count", default: 0, null: false
    t.integer "clicked_count", default: 0, null: false
    t.integer "failed_count", default: 0, null: false
    t.boolean "is_automated", default: false, null: false
    t.integer "recurrence_interval_days"
    t.datetime "scheduled_at"
    t.datetime "sent_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "email_template_id"
    t.bigint "email_provider_id"
    t.index ["created_by_id"], name: "index_email_campaigns_on_created_by_id"
    t.index ["email_provider_id"], name: "index_email_campaigns_on_email_provider_id"
    t.index ["email_template_id"], name: "index_email_campaigns_on_email_template_id"
    t.index ["organization_id", "is_automated"], name: "index_email_campaigns_on_organization_id_and_is_automated", where: "(is_automated = true)"
    t.index ["organization_id", "status"], name: "index_email_campaigns_on_organization_id_and_status"
    t.index ["organization_id"], name: "index_email_campaigns_on_organization_id"
    t.index ["scheduled_at"], name: "index_email_campaigns_on_scheduled_at", where: "(status = 1)"
    t.check_constraint "lapsed_days > 0", name: "email_campaigns_lapsed_days_positive_check"
    t.check_constraint "recurrence_interval_days IS NULL OR recurrence_interval_days > 0", name: "email_campaigns_recurrence_positive_check"
  end

  create_table "email_messages", force: :cascade do |t|
    t.bigint "email_campaign_id", null: false
    t.bigint "user_id", null: false
    t.string "to_email", null: false
    t.string "message_id"
    t.integer "status", default: 0, null: false
    t.string "error_message"
    t.datetime "opened_at"
    t.datetime "clicked_at"
    t.datetime "sent_at"
    t.datetime "delivered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider_message_id"
    t.index ["email_campaign_id", "status"], name: "index_email_messages_on_email_campaign_id_and_status"
    t.index ["email_campaign_id", "user_id"], name: "index_email_messages_on_email_campaign_id_and_user_id", unique: true
    t.index ["email_campaign_id"], name: "index_email_messages_on_email_campaign_id"
    t.index ["message_id"], name: "index_email_messages_on_message_id", unique: true, where: "(message_id IS NOT NULL)"
    t.index ["provider_message_id"], name: "index_email_messages_on_provider_message_id"
    t.index ["status", "sent_at"], name: "index_email_messages_on_status_and_sent_at"
    t.index ["user_id"], name: "index_email_messages_on_user_id"
  end

  create_table "email_providers", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "provider_type", null: false
    t.string "api_key", null: false
    t.string "from_email", null: false
    t.string "from_name"
    t.string "webhook_secret"
    t.boolean "is_active", default: true, null: false
    t.boolean "is_default", default: false, null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "last_verified_at"
    t.string "verification_status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "is_default"], name: "index_email_providers_on_organization_id_and_is_default"
    t.index ["organization_id", "provider_type"], name: "index_email_providers_on_organization_id_and_provider_type", unique: true
    t.index ["organization_id"], name: "index_email_providers_on_organization_id"
  end

  create_table "email_templates", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "created_by_id", null: false
    t.string "name", null: false
    t.string "subject", null: false
    t.text "body_html", null: false
    t.text "body_text"
    t.string "category", default: "general"
    t.boolean "is_active", default: true, null: false
    t.jsonb "merge_fields", default: [], null: false
    t.string "thumbnail_url"
    t.integer "usage_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_email_templates_on_created_by_id"
    t.index ["organization_id", "category"], name: "index_email_templates_on_organization_id_and_category"
    t.index ["organization_id", "is_active"], name: "index_email_templates_on_organization_id_and_is_active"
    t.index ["organization_id"], name: "index_email_templates_on_organization_id"
  end

  create_table "fnb_tab_items", force: :cascade do |t|
    t.bigint "fnb_tab_id", null: false
    t.string "name", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price_cents", null: false
    t.integer "total_cents", null: false
    t.string "category", default: "food", null: false
    t.text "notes"
    t.bigint "added_by_id", null: false, comment: "Staff member who added the item"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["added_by_id"], name: "index_fnb_tab_items_on_added_by_id"
    t.index ["fnb_tab_id", "created_at"], name: "index_fnb_tab_items_on_tab_and_created_at"
    t.index ["fnb_tab_id"], name: "index_fnb_tab_items_on_fnb_tab_id"
    t.check_constraint "category::text = ANY (ARRAY['food'::character varying::text, 'beverage'::character varying::text, 'other'::character varying::text])", name: "fnb_tab_items_category_check"
    t.check_constraint "quantity > 0", name: "fnb_tab_items_quantity_positive"
    t.check_constraint "total_cents >= 0", name: "fnb_tab_items_total_cents_non_negative"
    t.check_constraint "unit_price_cents >= 0", name: "fnb_tab_items_unit_price_non_negative"
  end

  create_table "fnb_tabs", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "course_id", null: false
    t.bigint "user_id", null: false, comment: "Server who opened the tab"
    t.string "golfer_name", null: false
    t.string "status", default: "open", null: false
    t.integer "total_cents", default: 0, null: false
    t.datetime "opened_at", null: false
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "booking_id"
    t.boolean "turn_order", default: false, null: false
    t.integer "delivery_hole"
    t.text "delivery_notes"
    t.index ["booking_id", "turn_order"], name: "index_fnb_tabs_on_booking_and_turn_order"
    t.index ["booking_id"], name: "index_fnb_tabs_on_booking_id"
    t.index ["course_id", "status"], name: "index_fnb_tabs_on_course_and_status"
    t.index ["course_id"], name: "index_fnb_tabs_on_course_id"
    t.index ["opened_at"], name: "index_fnb_tabs_on_opened_at"
    t.index ["organization_id", "status"], name: "index_fnb_tabs_on_org_and_status"
    t.index ["organization_id"], name: "index_fnb_tabs_on_organization_id"
    t.index ["user_id", "opened_at"], name: "index_fnb_tabs_on_user_and_opened_at"
    t.index ["user_id"], name: "index_fnb_tabs_on_user_id"
    t.check_constraint "status::text = ANY (ARRAY['open'::character varying::text, 'closed'::character varying::text, 'merged'::character varying::text])", name: "fnb_tabs_status_check"
    t.check_constraint "total_cents >= 0", name: "fnb_tabs_total_cents_non_negative"
  end

  create_table "golfer_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "handicap_index", precision: 4, scale: 1
    t.string "home_course"
    t.string "preferred_tee"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_golfer_profiles_on_user_id", unique: true
  end

  create_table "golfer_segment_memberships", force: :cascade do |t|
    t.bigint "golfer_segment_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["golfer_segment_id", "user_id"], name: "idx_segment_memberships_unique", unique: true
    t.index ["golfer_segment_id"], name: "index_golfer_segment_memberships_on_golfer_segment_id"
    t.index ["user_id"], name: "index_golfer_segment_memberships_on_user_id"
  end

  create_table "golfer_segments", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "created_by_id", null: false
    t.string "name", null: false
    t.text "description"
    t.jsonb "filter_criteria", default: {}, null: false
    t.boolean "is_dynamic", default: true, null: false
    t.integer "cached_count", default: 0, null: false
    t.datetime "last_evaluated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_golfer_segments_on_created_by_id"
    t.index ["filter_criteria"], name: "index_golfer_segments_on_filter_criteria", using: :gin
    t.index ["organization_id", "name"], name: "index_golfer_segments_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_golfer_segments_on_organization_id"
  end

  create_table "inventory_levels", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "pos_product_id", null: false
    t.bigint "course_id", null: false
    t.integer "current_stock", default: 0, null: false
    t.integer "reserved_stock", default: 0, null: false
    t.integer "reorder_point", default: 0, null: false
    t.integer "reorder_quantity", default: 0, null: false
    t.decimal "average_cost_cents", precision: 10, scale: 2
    t.decimal "last_cost_cents", precision: 10, scale: 2
    t.datetime "last_counted_at"
    t.bigint "last_counted_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_inventory_levels_on_course_id"
    t.index ["last_counted_by_id"], name: "index_inventory_levels_on_last_counted_by_id"
    t.index ["organization_id", "course_id"], name: "index_inventory_levels_on_org_and_course"
    t.index ["organization_id", "pos_product_id", "course_id"], name: "index_inventory_levels_unique", unique: true
    t.index ["organization_id"], name: "index_inventory_levels_low_stock", where: "(current_stock <= reorder_point)"
    t.index ["organization_id"], name: "index_inventory_levels_on_organization_id"
    t.index ["pos_product_id"], name: "index_inventory_levels_on_pos_product_id"
    t.check_constraint "current_stock >= 0", name: "inventory_levels_current_stock_non_negative"
    t.check_constraint "reorder_point >= 0", name: "inventory_levels_reorder_point_non_negative"
    t.check_constraint "reorder_quantity >= 0", name: "inventory_levels_reorder_quantity_non_negative"
    t.check_constraint "reserved_stock >= 0", name: "inventory_levels_reserved_stock_non_negative"
  end

  create_table "inventory_movements", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "pos_product_id", null: false
    t.bigint "course_id", null: false
    t.bigint "performed_by_id", null: false
    t.string "movement_type", null: false
    t.integer "quantity", null: false
    t.text "notes"
    t.string "reference_type"
    t.string "reference_id"
    t.decimal "unit_cost_cents", precision: 10, scale: 2
    t.decimal "total_cost_cents", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_inventory_movements_on_course_id"
    t.index ["organization_id", "course_id"], name: "index_inventory_movements_on_org_and_course"
    t.index ["organization_id", "movement_type"], name: "index_inventory_movements_on_org_and_type"
    t.index ["organization_id", "pos_product_id"], name: "index_inventory_movements_on_org_and_product"
    t.index ["organization_id"], name: "index_inventory_movements_on_organization_id"
    t.index ["performed_by_id"], name: "index_inventory_movements_on_performed_by_id"
    t.index ["pos_product_id"], name: "index_inventory_movements_on_pos_product_id"
    t.index ["reference_type", "reference_id"], name: "index_inventory_movements_on_reference"
    t.check_constraint "movement_type::text = ANY (ARRAY['receipt'::character varying::text, 'sale'::character varying::text, 'adjustment'::character varying::text, 'transfer_in'::character varying::text, 'transfer_out'::character varying::text])", name: "inventory_movements_type_check"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti", unique: true
  end

  create_table "loyalty_accounts", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.integer "points_balance", default: 0, null: false
    t.integer "lifetime_points", default: 0, null: false
    t.integer "tier", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "user_id"], name: "index_loyalty_accounts_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_loyalty_accounts_on_organization_id"
    t.index ["user_id"], name: "index_loyalty_accounts_on_user_id"
  end

  create_table "loyalty_programs", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.text "description"
    t.integer "points_per_dollar", default: 10, null: false
    t.boolean "is_active", default: true, null: false
    t.jsonb "tier_thresholds", default: {"gold"=>2000, "silver"=>500, "platinum"=>5000}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_loyalty_programs_on_organization_id"
  end

  create_table "loyalty_redemptions", force: :cascade do |t|
    t.bigint "loyalty_account_id", null: false
    t.bigint "loyalty_reward_id", null: false
    t.bigint "booking_id"
    t.integer "status", default: 0, null: false
    t.string "code", null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_loyalty_redemptions_on_booking_id"
    t.index ["code"], name: "index_loyalty_redemptions_on_code", unique: true
    t.index ["expires_at"], name: "index_loyalty_redemptions_on_expires_at"
    t.index ["loyalty_account_id"], name: "index_loyalty_redemptions_on_loyalty_account_id"
    t.index ["loyalty_reward_id"], name: "index_loyalty_redemptions_on_loyalty_reward_id"
    t.index ["status"], name: "index_loyalty_redemptions_on_status"
  end

  create_table "loyalty_rewards", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.text "description"
    t.integer "points_cost", null: false
    t.integer "reward_type", null: false
    t.integer "discount_value"
    t.boolean "is_active", default: true, null: false
    t.integer "max_redemptions_per_user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_loyalty_rewards_on_is_active"
    t.index ["organization_id"], name: "index_loyalty_rewards_on_organization_id"
    t.index ["reward_type"], name: "index_loyalty_rewards_on_reward_type"
  end

  create_table "loyalty_transactions", force: :cascade do |t|
    t.bigint "loyalty_account_id", null: false
    t.string "source_type"
    t.bigint "source_id"
    t.integer "transaction_type", null: false
    t.integer "points", null: false
    t.string "description", null: false
    t.integer "balance_after", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_loyalty_transactions_on_created_at"
    t.index ["loyalty_account_id"], name: "index_loyalty_transactions_on_loyalty_account_id"
    t.index ["source_type", "source_id"], name: "index_loyalty_transactions_on_source"
    t.index ["transaction_type"], name: "index_loyalty_transactions_on_transaction_type"
  end

  create_table "marketplace_connections", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "course_id", null: false
    t.string "provider", null: false
    t.integer "status", default: 0, null: false
    t.string "external_course_id"
    t.jsonb "credentials", default: {}, null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "last_synced_at"
    t.string "last_error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_marketplace_connections_on_course_id"
    t.index ["organization_id", "course_id", "provider"], name: "idx_marketplace_connections_org_course_provider", unique: true
    t.index ["organization_id"], name: "index_marketplace_connections_on_organization_id"
    t.index ["provider", "status"], name: "index_marketplace_connections_on_provider_and_status"
  end

  create_table "marketplace_listings", force: :cascade do |t|
    t.bigint "marketplace_connection_id", null: false
    t.bigint "tee_time_id", null: false
    t.string "external_listing_id"
    t.integer "status", default: 0, null: false
    t.integer "listed_price_cents"
    t.string "listed_price_currency", default: "USD"
    t.integer "commission_rate_bps"
    t.datetime "listed_at"
    t.datetime "expires_at"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_listing_id"], name: "idx_marketplace_listings_external_id"
    t.index ["marketplace_connection_id", "tee_time_id"], name: "idx_marketplace_listings_connection_tee_time", unique: true
    t.index ["marketplace_connection_id"], name: "index_marketplace_listings_on_marketplace_connection_id"
    t.index ["status"], name: "index_marketplace_listings_on_status"
    t.index ["tee_time_id"], name: "index_marketplace_listings_on_tee_time_id"
  end

  create_table "member_account_charges", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "membership_id", null: false
    t.bigint "charged_by_id", null: false
    t.bigint "fnb_tab_id"
    t.bigint "booking_id"
    t.string "charge_type", default: "fnb", null: false
    t.string "status", default: "pending", null: false
    t.integer "amount_cents", null: false
    t.string "amount_currency", default: "USD", null: false
    t.text "description"
    t.text "notes"
    t.datetime "posted_at"
    t.datetime "voided_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_member_account_charges_on_booking_id"
    t.index ["charge_type"], name: "index_member_account_charges_on_charge_type"
    t.index ["charged_by_id"], name: "index_member_account_charges_on_charged_by_id"
    t.index ["fnb_tab_id"], name: "index_member_account_charges_on_fnb_tab_id"
    t.index ["membership_id", "status"], name: "idx_member_charges_membership_status"
    t.index ["membership_id"], name: "index_member_account_charges_on_membership_id"
    t.index ["organization_id", "created_at"], name: "idx_member_charges_org_created"
    t.index ["organization_id", "membership_id"], name: "idx_member_charges_org_membership"
    t.index ["organization_id"], name: "index_member_account_charges_on_organization_id"
    t.index ["status"], name: "index_member_account_charges_on_status"
    t.check_constraint "amount_cents > 0", name: "member_account_charges_amount_positive"
    t.check_constraint "charge_type::text = ANY (ARRAY['fnb'::character varying::text, 'booking'::character varying::text, 'pro_shop'::character varying::text, 'dues'::character varying::text, 'other'::character varying::text])", name: "member_account_charges_type_check"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying::text, 'posted'::character varying::text, 'voided'::character varying::text, 'paid'::character varying::text])", name: "member_account_charges_status_check"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.integer "tier", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "price_cents"
    t.string "price_currency", default: "USD"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean "auto_renew", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_balance_cents", default: 0, null: false
    t.integer "credit_limit_cents", default: 500000, null: false
    t.index ["organization_id", "user_id"], name: "index_memberships_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["status"], name: "index_memberships_on_status"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "stripe_account_id"
    t.string "phone"
    t.string "email"
    t.string "address"
    t.string "timezone", default: "UTC"
    t.string "logo_url"
    t.jsonb "settings", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.string "stripe_payment_intent_id"
    t.integer "amount_cents", null: false
    t.string "amount_currency", default: "USD", null: false
    t.integer "refund_amount_cents"
    t.string "refund_amount_currency"
    t.integer "status", default: 0, null: false
    t.string "stripe_charge_id"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_payments_on_booking_id"
    t.index ["status"], name: "index_payments_on_status"
    t.index ["stripe_payment_intent_id"], name: "index_payments_on_stripe_payment_intent_id", unique: true
  end

  create_table "pos_products", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "course_id", null: false
    t.string "name", null: false
    t.string "sku", null: false
    t.string "barcode"
    t.integer "price_cents", null: false
    t.string "category", default: "other", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.integer "stock_quantity"
    t.boolean "track_inventory", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_pos_products_on_course_id"
    t.index ["organization_id", "active"], name: "index_pos_products_on_org_and_active"
    t.index ["organization_id", "barcode"], name: "index_pos_products_on_org_and_barcode", unique: true, where: "(barcode IS NOT NULL)"
    t.index ["organization_id", "category"], name: "index_pos_products_on_org_and_category"
    t.index ["organization_id", "sku"], name: "index_pos_products_on_org_and_sku", unique: true
    t.index ["organization_id"], name: "index_pos_products_on_organization_id"
    t.check_constraint "category::text = ANY (ARRAY['food'::character varying::text, 'beverage'::character varying::text, 'apparel'::character varying::text, 'equipment'::character varying::text, 'rental'::character varying::text, 'other'::character varying::text])", name: "pos_products_category_check"
    t.check_constraint "price_cents >= 0", name: "pos_products_price_non_negative"
  end

  create_table "pricing_rules", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "course_id"
    t.string "name", null: false
    t.string "rule_type", null: false
    t.jsonb "conditions", default: {}
    t.decimal "multiplier", precision: 10, scale: 4, default: "1.0"
    t.integer "flat_adjustment_cents", default: 0
    t.integer "priority", default: 0
    t.boolean "active", default: true
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_pricing_rules_on_course_id"
    t.index ["organization_id", "active"], name: "index_pricing_rules_on_organization_id_and_active"
    t.index ["organization_id", "course_id"], name: "index_pricing_rules_on_organization_id_and_course_id"
    t.index ["organization_id", "rule_type"], name: "index_pricing_rules_on_organization_id_and_rule_type"
    t.index ["organization_id"], name: "index_pricing_rules_on_organization_id"
    t.index ["priority"], name: "index_pricing_rules_on_priority"
  end

  create_table "sms_campaigns", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "created_by_id", null: false
    t.string "name", null: false
    t.text "message_body", null: false
    t.integer "status", default: 0, null: false
    t.string "recipient_filter", default: "all", null: false
    t.jsonb "filter_criteria", default: {}, null: false
    t.integer "total_recipients", default: 0, null: false
    t.integer "sent_count", default: 0, null: false
    t.integer "delivered_count", default: 0, null: false
    t.integer "failed_count", default: 0, null: false
    t.datetime "scheduled_at"
    t.datetime "sent_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_sms_campaigns_on_created_by_id"
    t.index ["organization_id", "status"], name: "index_sms_campaigns_on_organization_id_and_status"
    t.index ["organization_id"], name: "index_sms_campaigns_on_organization_id"
    t.index ["scheduled_at"], name: "index_sms_campaigns_on_scheduled_at", where: "(status = 1)"
    t.check_constraint "char_length(message_body) <= 1600", name: "sms_campaigns_message_length_check"
  end

  create_table "sms_messages", force: :cascade do |t|
    t.bigint "sms_campaign_id", null: false
    t.bigint "user_id", null: false
    t.string "to_phone", null: false
    t.string "twilio_sid"
    t.integer "status", default: 0, null: false
    t.string "error_code"
    t.string "error_message"
    t.datetime "sent_at"
    t.datetime "delivered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sms_campaign_id", "status"], name: "index_sms_messages_on_sms_campaign_id_and_status"
    t.index ["sms_campaign_id", "user_id"], name: "index_sms_messages_on_sms_campaign_id_and_user_id", unique: true
    t.index ["sms_campaign_id"], name: "index_sms_messages_on_sms_campaign_id"
    t.index ["twilio_sid"], name: "index_sms_messages_on_twilio_sid", unique: true, where: "(twilio_sid IS NOT NULL)"
    t.index ["user_id"], name: "index_sms_messages_on_user_id"
  end

  create_table "stripe_events", force: :cascade do |t|
    t.string "stripe_event_id", null: false
    t.string "event_type", null: false
    t.integer "status", default: 0, null: false
    t.jsonb "payload", null: false
    t.datetime "processed_at"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_stripe_events_on_event_type"
    t.index ["status"], name: "index_stripe_events_on_status"
    t.index ["stripe_event_id"], name: "index_stripe_events_on_stripe_event_id", unique: true
  end

  create_table "tee_sheets", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.date "date", null: false
    t.text "notes"
    t.datetime "generated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "date"], name: "index_tee_sheets_on_course_id_and_date", unique: true
    t.index ["course_id"], name: "index_tee_sheets_on_course_id"
  end

  create_table "tee_times", force: :cascade do |t|
    t.bigint "tee_sheet_id", null: false
    t.datetime "starts_at", null: false
    t.integer "max_players", default: 4, null: false
    t.integer "booked_players", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "price_cents"
    t.string "price_currency", default: "USD"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["starts_at"], name: "index_tee_times_on_starts_at"
    t.index ["status"], name: "index_tee_times_on_status"
    t.index ["tee_sheet_id"], name: "index_tee_times_on_tee_sheet_id"
  end

  create_table "tournament_entries", force: :cascade do |t|
    t.bigint "tournament_id", null: false
    t.bigint "user_id", null: false
    t.bigint "payment_id"
    t.integer "status", default: 0, null: false
    t.string "team_name"
    t.decimal "handicap_index", precision: 4, scale: 1
    t.integer "starting_hole"
    t.time "tee_time"
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_tournament_entries_on_payment_id"
    t.index ["status"], name: "index_tournament_entries_on_status"
    t.index ["tournament_id", "user_id"], name: "index_tournament_entries_on_tournament_id_and_user_id", unique: true
    t.index ["tournament_id"], name: "index_tournament_entries_on_tournament_id"
    t.index ["user_id"], name: "index_tournament_entries_on_user_id"
  end

  create_table "tournament_prizes", force: :cascade do |t|
    t.bigint "tournament_id", null: false
    t.integer "position", null: false
    t.string "prize_type", null: false
    t.text "description", null: false
    t.integer "amount_cents", default: 0, null: false
    t.bigint "awarded_to_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["awarded_to_id"], name: "index_tournament_prizes_on_awarded_to_id"
    t.index ["prize_type"], name: "index_tournament_prizes_on_prize_type"
    t.index ["tournament_id", "position"], name: "index_tournament_prizes_on_tournament_id_and_position", unique: true
    t.index ["tournament_id"], name: "index_tournament_prizes_on_tournament_id"
  end

  create_table "tournament_results", force: :cascade do |t|
    t.bigint "tournament_id", null: false
    t.bigint "tournament_entry_id", null: false
    t.integer "position", null: false
    t.integer "total_strokes", null: false
    t.integer "total_to_par", null: false
    t.boolean "tied", default: false, null: false
    t.boolean "prize_awarded", default: false, null: false
    t.datetime "finalized_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "index_tournament_results_on_position"
    t.index ["tournament_entry_id"], name: "index_tournament_results_on_tournament_entry_id"
    t.index ["tournament_id", "position"], name: "index_tournament_results_on_tournament_id_and_position"
    t.index ["tournament_id", "tournament_entry_id"], name: "idx_on_tournament_id_tournament_entry_id_b7b8121d49", unique: true
    t.index ["tournament_id"], name: "index_tournament_results_on_tournament_id"
  end

  create_table "tournament_rounds", force: :cascade do |t|
    t.bigint "tournament_id", null: false
    t.integer "round_number", default: 1, null: false
    t.date "play_date", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id", "round_number"], name: "index_tournament_rounds_on_tournament_id_and_round_number", unique: true
    t.index ["tournament_id"], name: "index_tournament_rounds_on_tournament_id"
  end

  create_table "tournament_scores", force: :cascade do |t|
    t.bigint "tournament_round_id", null: false
    t.bigint "tournament_entry_id", null: false
    t.integer "hole_number", null: false
    t.integer "strokes", null: false
    t.integer "par", null: false
    t.integer "putts"
    t.boolean "fairway_hit"
    t.boolean "green_in_regulation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_entry_id"], name: "index_tournament_scores_on_tournament_entry_id"
    t.index ["tournament_round_id", "tournament_entry_id", "hole_number"], name: "idx_scores_on_round_entry_hole", unique: true
    t.index ["tournament_round_id"], name: "index_tournament_scores_on_tournament_round_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "organization_id", null: false
    t.bigint "created_by_id", null: false
    t.string "name", null: false
    t.text "description"
    t.integer "format", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "max_participants"
    t.integer "min_participants", default: 2
    t.integer "team_size", default: 1
    t.integer "entry_fee_cents", default: 0
    t.string "entry_fee_currency", default: "USD"
    t.integer "holes", default: 18
    t.boolean "handicap_enabled", default: true
    t.decimal "max_handicap", precision: 4, scale: 1
    t.json "rules", default: {}
    t.json "prize_structure", default: {}
    t.datetime "registration_opens_at"
    t.datetime "registration_closes_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "start_date"], name: "index_tournaments_on_course_id_and_start_date"
    t.index ["course_id"], name: "index_tournaments_on_course_id"
    t.index ["created_by_id"], name: "index_tournaments_on_created_by_id"
    t.index ["organization_id", "start_date"], name: "index_tournaments_on_organization_id_and_start_date"
    t.index ["organization_id"], name: "index_tournaments_on_organization_id"
    t.index ["status"], name: "index_tournaments_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.bigint "organization_id", null: false
    t.integer "role", default: 0, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "marketplace_source"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["marketplace_source"], name: "index_users_on_marketplace_source", where: "(marketplace_source IS NOT NULL)"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "voice_call_logs", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "course_id"
    t.string "call_sid"
    t.string "channel", default: "browser", null: false
    t.string "caller_phone"
    t.string "caller_name"
    t.string "status", default: "in_progress", null: false
    t.integer "duration_seconds"
    t.jsonb "transcript", default: [], null: false
    t.jsonb "summary", default: {}, null: false
    t.datetime "started_at", null: false
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["call_sid"], name: "index_voice_call_logs_on_call_sid", unique: true, where: "(call_sid IS NOT NULL)"
    t.index ["channel"], name: "index_voice_call_logs_on_channel"
    t.index ["course_id"], name: "index_voice_call_logs_on_course_id"
    t.index ["organization_id", "started_at"], name: "index_voice_call_logs_on_organization_id_and_started_at"
    t.index ["organization_id"], name: "index_voice_call_logs_on_organization_id"
    t.index ["status"], name: "index_voice_call_logs_on_status"
  end

  create_table "webhook_endpoints", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "url", null: false
    t.string "secret", null: false
    t.json "events", default: [], null: false
    t.boolean "active", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_webhook_endpoints_on_active"
    t.index ["organization_id", "url"], name: "index_webhook_endpoints_on_organization_id_and_url", unique: true
    t.index ["organization_id"], name: "index_webhook_endpoints_on_organization_id"
    t.check_constraint "url::text ~~ 'https://%'::text", name: "webhook_endpoints_url_https_check"
  end

  create_table "webhook_events", force: :cascade do |t|
    t.bigint "webhook_endpoint_id", null: false
    t.string "event_type", null: false
    t.json "payload", default: {}, null: false
    t.integer "status", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.datetime "last_attempted_at"
    t.datetime "delivered_at"
    t.integer "response_code"
    t.text "response_body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_webhook_events_on_event_type"
    t.index ["last_attempted_at"], name: "index_webhook_events_on_last_attempted_at"
    t.index ["status", "created_at"], name: "index_webhook_events_on_status_and_created_at"
    t.index ["webhook_endpoint_id", "created_at"], name: "index_webhook_events_on_webhook_endpoint_id_and_created_at"
    t.index ["webhook_endpoint_id"], name: "index_webhook_events_on_webhook_endpoint_id"
    t.check_constraint "attempts >= 0", name: "webhook_events_attempts_positive_check"
    t.check_constraint "response_code >= 100 AND response_code <= 599", name: "webhook_events_response_code_valid_check"
  end

  add_foreign_key "api_keys", "organizations"
  add_foreign_key "booking_players", "bookings", on_delete: :cascade
  add_foreign_key "booking_players", "golfer_profiles", on_delete: :nullify
  add_foreign_key "bookings", "tee_times", on_delete: :cascade
  add_foreign_key "bookings", "users", on_delete: :cascade
  add_foreign_key "courses", "organizations", on_delete: :cascade
  add_foreign_key "email_campaigns", "email_providers"
  add_foreign_key "email_campaigns", "email_templates"
  add_foreign_key "email_campaigns", "organizations", on_delete: :cascade
  add_foreign_key "email_campaigns", "users", column: "created_by_id", on_delete: :cascade
  add_foreign_key "email_messages", "email_campaigns", on_delete: :cascade
  add_foreign_key "email_messages", "users", on_delete: :cascade
  add_foreign_key "email_providers", "organizations"
  add_foreign_key "email_templates", "organizations"
  add_foreign_key "email_templates", "users", column: "created_by_id"
  add_foreign_key "fnb_tab_items", "fnb_tabs"
  add_foreign_key "fnb_tab_items", "users", column: "added_by_id"
  add_foreign_key "fnb_tabs", "bookings"
  add_foreign_key "fnb_tabs", "courses"
  add_foreign_key "fnb_tabs", "organizations"
  add_foreign_key "fnb_tabs", "users"
  add_foreign_key "golfer_profiles", "users", on_delete: :cascade
  add_foreign_key "golfer_segment_memberships", "golfer_segments", on_delete: :cascade
  add_foreign_key "golfer_segment_memberships", "users", on_delete: :cascade
  add_foreign_key "golfer_segments", "organizations", on_delete: :cascade
  add_foreign_key "golfer_segments", "users", column: "created_by_id"
  add_foreign_key "inventory_levels", "courses"
  add_foreign_key "inventory_levels", "organizations"
  add_foreign_key "inventory_levels", "pos_products"
  add_foreign_key "inventory_levels", "users", column: "last_counted_by_id"
  add_foreign_key "inventory_movements", "courses"
  add_foreign_key "inventory_movements", "organizations"
  add_foreign_key "inventory_movements", "pos_products"
  add_foreign_key "inventory_movements", "users", column: "performed_by_id"
  add_foreign_key "loyalty_accounts", "organizations"
  add_foreign_key "loyalty_accounts", "users"
  add_foreign_key "loyalty_programs", "organizations"
  add_foreign_key "loyalty_redemptions", "bookings"
  add_foreign_key "loyalty_redemptions", "loyalty_accounts"
  add_foreign_key "loyalty_redemptions", "loyalty_rewards"
  add_foreign_key "loyalty_rewards", "organizations"
  add_foreign_key "loyalty_transactions", "loyalty_accounts"
  add_foreign_key "marketplace_connections", "courses"
  add_foreign_key "marketplace_connections", "organizations"
  add_foreign_key "marketplace_listings", "marketplace_connections"
  add_foreign_key "marketplace_listings", "tee_times"
  add_foreign_key "member_account_charges", "bookings"
  add_foreign_key "member_account_charges", "fnb_tabs"
  add_foreign_key "member_account_charges", "memberships"
  add_foreign_key "member_account_charges", "organizations"
  add_foreign_key "member_account_charges", "users", column: "charged_by_id"
  add_foreign_key "memberships", "organizations", on_delete: :cascade
  add_foreign_key "memberships", "users", on_delete: :cascade
  add_foreign_key "payments", "bookings", on_delete: :cascade
  add_foreign_key "pos_products", "courses"
  add_foreign_key "pos_products", "organizations"
  add_foreign_key "pricing_rules", "courses"
  add_foreign_key "pricing_rules", "organizations"
  add_foreign_key "sms_campaigns", "organizations", on_delete: :cascade
  add_foreign_key "sms_campaigns", "users", column: "created_by_id", on_delete: :cascade
  add_foreign_key "sms_messages", "sms_campaigns", on_delete: :cascade
  add_foreign_key "sms_messages", "users", on_delete: :cascade
  add_foreign_key "tee_sheets", "courses", on_delete: :cascade
  add_foreign_key "tee_times", "tee_sheets", on_delete: :cascade
  add_foreign_key "tournament_entries", "payments", on_delete: :nullify
  add_foreign_key "tournament_entries", "tournaments", on_delete: :cascade
  add_foreign_key "tournament_entries", "users", on_delete: :cascade
  add_foreign_key "tournament_prizes", "tournament_entries", column: "awarded_to_id"
  add_foreign_key "tournament_prizes", "tournaments"
  add_foreign_key "tournament_results", "tournament_entries"
  add_foreign_key "tournament_results", "tournaments"
  add_foreign_key "tournament_rounds", "tournaments"
  add_foreign_key "tournament_scores", "tournament_entries"
  add_foreign_key "tournament_scores", "tournament_rounds"
  add_foreign_key "tournaments", "courses", on_delete: :cascade
  add_foreign_key "tournaments", "organizations", on_delete: :cascade
  add_foreign_key "tournaments", "users", column: "created_by_id"
  add_foreign_key "users", "organizations", on_delete: :cascade
  add_foreign_key "voice_call_logs", "courses", on_delete: :nullify
  add_foreign_key "voice_call_logs", "organizations", on_delete: :cascade
  add_foreign_key "webhook_endpoints", "organizations"
  add_foreign_key "webhook_events", "webhook_endpoints"
end
