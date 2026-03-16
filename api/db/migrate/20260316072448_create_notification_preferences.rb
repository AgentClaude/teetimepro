class CreateNotificationPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_preferences, id: :bigint do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.boolean :email_booking_confirmation, default: true
      t.boolean :email_booking_cancellation, default: true
      t.boolean :email_booking_reminder, default: true
      t.boolean :email_marketing, default: false
      t.boolean :sms_booking_confirmation, default: true
      t.boolean :sms_booking_cancellation, default: false
      t.boolean :sms_booking_reminder, default: true
      t.boolean :sms_marketing, default: false
      t.boolean :push_booking_confirmation, default: true
      t.boolean :push_booking_cancellation, default: true
      t.boolean :push_booking_reminder, default: true
      t.boolean :push_marketing, default: false
      t.integer :reminder_hours_before, default: 24
      t.timestamps
    end
  end
end
