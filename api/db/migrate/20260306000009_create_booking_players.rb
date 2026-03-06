class CreateBookingPlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :booking_players do |t|
      t.references :booking, null: false, foreign_key: { on_delete: :cascade }
      t.references :golfer_profile, foreign_key: { on_delete: :nullify }
      t.string :name
      t.string :email
      t.string :phone

      t.timestamps
    end
  end
end
