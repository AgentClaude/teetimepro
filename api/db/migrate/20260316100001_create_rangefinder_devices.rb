class CreateRangefinderDevices < ActiveRecord::Migration[8.0]
  def change
    create_table :rangefinder_devices do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :device_id, null: false
      t.string :name, null: false
      t.integer :device_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.string :firmware_version
      t.decimal :battery_level, precision: 5, scale: 2
      t.datetime :last_seen_at
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :rangefinder_devices, [:organization_id, :device_id], unique: true
  end
end
