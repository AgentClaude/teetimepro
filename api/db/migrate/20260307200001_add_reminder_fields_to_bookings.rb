class AddReminderFieldsToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :reminder_sent_at, :datetime
    add_column :bookings, :morning_reminder_sent_at, :datetime

    add_index :bookings, :reminder_sent_at
    add_index :bookings, :morning_reminder_sent_at
  end
end
