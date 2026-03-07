class CreateEmailCampaigns < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      create_table :email_campaigns do |t|
        t.references :organization, null: false, foreign_key: { on_delete: :cascade }
        t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
        t.string :name, null: false
        t.string :subject, null: false
        t.text :body_html, null: false
        t.text :body_text
        t.integer :status, default: 0, null: false
        t.string :recipient_filter, default: "all", null: false
        t.jsonb :filter_criteria, default: {}, null: false
        t.integer :lapsed_days, default: 30, null: false
        t.integer :total_recipients, default: 0, null: false
        t.integer :sent_count, default: 0, null: false
        t.integer :delivered_count, default: 0, null: false
        t.integer :opened_count, default: 0, null: false
        t.integer :clicked_count, default: 0, null: false
        t.integer :failed_count, default: 0, null: false
        t.boolean :is_automated, default: false, null: false
        t.integer :recurrence_interval_days
        t.datetime :scheduled_at
        t.datetime :sent_at
        t.datetime :completed_at

        t.timestamps
      end

      add_index :email_campaigns, [:organization_id, :status]
      add_index :email_campaigns, :scheduled_at, where: "status = 1"
      add_index :email_campaigns, [:organization_id, :is_automated], where: "is_automated = true"
      add_check_constraint :email_campaigns, "lapsed_days > 0", name: "email_campaigns_lapsed_days_positive_check"
      add_check_constraint :email_campaigns, "recurrence_interval_days IS NULL OR recurrence_interval_days > 0", name: "email_campaigns_recurrence_positive_check"
    end
  end
end
