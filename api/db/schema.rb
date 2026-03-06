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

ActiveRecord::Schema[8.0].define(version: 2026_03_06_000011) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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
    t.index ["active"], name: "index_courses_on_active"
    t.index ["organization_id", "name"], name: "index_courses_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_courses_on_organization_id"
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

  add_foreign_key "booking_players", "bookings", on_delete: :cascade
  add_foreign_key "booking_players", "golfer_profiles", on_delete: :nullify
  add_foreign_key "bookings", "tee_times", on_delete: :cascade
  add_foreign_key "bookings", "users", on_delete: :cascade
  add_foreign_key "courses", "organizations", on_delete: :cascade
  add_foreign_key "golfer_profiles", "users", on_delete: :cascade
  add_foreign_key "memberships", "organizations", on_delete: :cascade
  add_foreign_key "memberships", "users", on_delete: :cascade
  add_foreign_key "payments", "bookings", on_delete: :cascade
  add_foreign_key "tee_sheets", "courses", on_delete: :cascade
  add_foreign_key "tee_times", "tee_sheets", on_delete: :cascade
  add_foreign_key "users", "organizations", on_delete: :cascade
end
