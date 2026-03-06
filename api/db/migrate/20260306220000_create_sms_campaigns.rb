class CreateSmsCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :sms_campaigns do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.string :name, null: false
      t.text :message_body, null: false
      t.integer :status, default: 0, null: false
      t.string :recipient_filter, default: "all", null: false
      t.jsonb :filter_criteria, default: {}, null: false
      t.integer :total_recipients, default: 0, null: false
      t.integer :sent_count, default: 0, null: false
      t.integer :delivered_count, default: 0, null: false
      t.integer :failed_count, default: 0, null: false
      t.datetime :scheduled_at
      t.datetime :sent_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :sms_campaigns, [:organization_id, :status]
    add_index :sms_campaigns, :scheduled_at, where: "status = 1"
    add_check_constraint :sms_campaigns, "char_length(message_body) <= 1600", name: "sms_campaigns_message_length_check"
  end
end
