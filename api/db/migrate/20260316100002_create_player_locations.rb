class CreatePlayerLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :player_locations do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.references :rangefinder_device, foreign_key: true
      t.decimal :latitude, precision: 10, scale: 7, null: false
      t.decimal :longitude, precision: 10, scale: 7, null: false
      t.decimal :accuracy_meters, precision: 8, scale: 2
      t.integer :current_hole
      t.datetime :recorded_at, null: false

      t.timestamps
    end

    add_index :player_locations, [:booking_id, :recorded_at]
    add_index :player_locations, [:course_id, :recorded_at]
  end
end
