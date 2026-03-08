class AddWalkOnFieldsToBookings < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_column :bookings, :booking_type, :integer, default: 0, null: false
      add_column :bookings, :guest_name, :string
      add_column :bookings, :guest_email, :string
      add_column :bookings, :guest_phone, :string
      add_column :bookings, :created_by_id, :bigint
      add_column :bookings, :walk_on_notes, :text
      add_foreign_key :bookings, :users, column: :created_by_id
    end

    add_index :bookings, :booking_type, algorithm: :concurrently
    add_index :bookings, :created_by_id, algorithm: :concurrently
  end
end
