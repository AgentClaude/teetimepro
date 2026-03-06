class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.integer :holes, default: 18, null: false
      t.integer :interval_minutes, default: 8, null: false
      t.time :first_tee_time
      t.time :last_tee_time
      t.integer :max_players_per_slot, default: 4, null: false

      # Rates (using money-rails pattern)
      t.integer :weekday_rate_cents
      t.integer :weekend_rate_cents
      t.integer :twilight_rate_cents
      t.string :weekday_rate_currency, default: "USD"
      t.string :weekend_rate_currency, default: "USD"
      t.string :twilight_rate_currency, default: "USD"

      # Location
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone
      t.string :website
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.string :timezone, default: "UTC"

      t.jsonb :settings, default: {}
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :courses, :active
    add_index :courses, %i[organization_id name], unique: true
  end
end
