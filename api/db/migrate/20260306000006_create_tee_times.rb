class CreateTeeTimes < ActiveRecord::Migration[8.0]
  def change
    create_table :tee_times do |t|
      t.references :tee_sheet, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :starts_at, null: false
      t.integer :max_players, default: 4, null: false
      t.integer :booked_players, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.integer :price_cents
      t.string :price_currency, default: "USD"
      t.text :notes

      t.timestamps
    end

    add_index :tee_times, :starts_at
    add_index :tee_times, :status
  end
end
