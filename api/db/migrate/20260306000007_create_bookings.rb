class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :tee_time, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :confirmation_code, null: false
      t.integer :players_count, default: 1, null: false
      t.integer :total_cents
      t.string :total_currency, default: "USD"
      t.integer :status, default: 0, null: false
      t.text :notes
      t.datetime :checked_in_at
      t.datetime :cancelled_at
      t.text :cancellation_reason

      t.timestamps
    end

    add_index :bookings, :confirmation_code, unique: true
    add_index :bookings, :status
  end
end
