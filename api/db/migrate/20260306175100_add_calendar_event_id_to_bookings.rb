class AddCalendarEventIdToBookings < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :bookings, :calendar_event_id, :string
    add_index :bookings, :calendar_event_id, algorithm: :concurrently
  end
end