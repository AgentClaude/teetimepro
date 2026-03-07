class CreateEmailMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :email_messages do |t|
      t.references :email_campaign, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :to_email, null: false
      t.string :message_id # Email service provider message ID
      t.integer :status, default: 0, null: false
      t.string :error_message
      t.datetime :opened_at
      t.datetime :clicked_at
      t.datetime :sent_at
      t.datetime :delivered_at

      t.timestamps
    end

    add_index :email_messages, [:email_campaign_id, :status]
    add_index :email_messages, :message_id, unique: true, where: "message_id IS NOT NULL"
    add_index :email_messages, [:email_campaign_id, :user_id], unique: true
    add_index :email_messages, [:status, :sent_at]
  end
end