class AddCalendarEventIdToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :calendar_event_id, :string
    add_index :bookings, :calendar_event_id
  end
end