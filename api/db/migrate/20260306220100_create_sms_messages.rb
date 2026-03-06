class CreateSmsMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :sms_messages do |t|
      t.references :sms_campaign, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :to_phone, null: false
      t.string :twilio_sid
      t.integer :status, default: 0, null: false
      t.string :error_code
      t.string :error_message
      t.datetime :sent_at
      t.datetime :delivered_at

      t.timestamps
    end

    add_index :sms_messages, [:sms_campaign_id, :status]
    add_index :sms_messages, :twilio_sid, unique: true, where: "twilio_sid IS NOT NULL"
    add_index :sms_messages, [:sms_campaign_id, :user_id], unique: true
  end
end
