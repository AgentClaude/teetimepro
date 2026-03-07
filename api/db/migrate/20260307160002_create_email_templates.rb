# frozen_string_literal: true

class CreateEmailTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :email_templates do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.string :subject, null: false
      t.text :body_html, null: false
      t.text :body_text
      t.string :category, default: "general" # general, re-engagement, promotion, newsletter, transactional
      t.boolean :is_active, null: false, default: true
      t.jsonb :merge_fields, null: false, default: [] # available merge fields
      t.string :thumbnail_url
      t.integer :usage_count, null: false, default: 0

      t.timestamps
    end

    add_index :email_templates, [:organization_id, :category]
    add_index :email_templates, [:organization_id, :is_active]

    # Add template/provider references to email campaigns and provider_message_id to email_messages
    safety_assured do
      add_reference :email_campaigns, :email_template, foreign_key: true, null: true
      add_reference :email_campaigns, :email_provider, foreign_key: true, null: true
      add_column :email_messages, :provider_message_id, :string
      add_index :email_messages, :provider_message_id
    end
  end
end
