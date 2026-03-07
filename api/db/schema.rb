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

ActiveRecord::Schema[8.0].define(version: 2026_03_07_010000) do
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
    t.index ["active"], name: "index_courses_on_active"
    t.index ["organization_id", "name"], name: "index_courses_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_courses_on_organization_id"
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

  create_table "golfer_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "handicap_index", precision: 4, scale: 1
    t.string "home_course"
    t.string "preferred_tee"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_golfer_profiles_on_user_id", unique: true
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti", unique: true
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
    t.index ["email"], name: "index_users_on_email", unique: true
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
  add_foreign_key "golfer_segment_memberships", "golfer_segments", on_delete: :cascade
  add_foreign_key "golfer_segment_memberships", "users", on_delete: :cascade
  add_foreign_key "golfer_segments", "organizations", on_delete: :cascade
  add_foreign_key "golfer_segments", "users", column: "created_by_id"
  add_foreign_key "golfer_profiles", "users", on_delete: :cascade
  add_foreign_key "memberships", "organizations", on_delete: :cascade
  add_foreign_key "memberships", "users", on_delete: :cascade
  add_foreign_key "payments", "bookings", on_delete: :cascade
  add_foreign_key "sms_campaigns", "organizations", on_delete: :cascade
  add_foreign_key "sms_campaigns", "users", column: "created_by_id", on_delete: :cascade
  add_foreign_key "sms_messages", "sms_campaigns", on_delete: :cascade
  add_foreign_key "sms_messages", "users", on_delete: :cascade
  add_foreign_key "tee_sheets", "courses", on_delete: :cascade
  add_foreign_key "tee_times", "tee_sheets", on_delete: :cascade
  add_foreign_key "tournament_entries", "payments", on_delete: :nullify
  add_foreign_key "tournament_entries", "tournaments", on_delete: :cascade
  add_foreign_key "tournament_entries", "users", on_delete: :cascade
  add_foreign_key "tournaments", "courses", on_delete: :cascade
  add_foreign_key "tournaments", "organizations", on_delete: :cascade
  add_foreign_key "tournaments", "users", column: "created_by_id"
  add_foreign_key "users", "organizations", on_delete: :cascade
  add_foreign_key "voice_call_logs", "courses", on_delete: :nullify
  add_foreign_key "voice_call_logs", "organizations", on_delete: :cascade
  add_foreign_key "webhook_endpoints", "organizations"
  add_foreign_key "webhook_events", "webhook_endpoints"
end
