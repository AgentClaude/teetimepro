# frozen_string_literal: true

class CreateEmailProviders < ActiveRecord::Migration[8.0]
  def change
    create_table :email_providers do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :provider_type, null: false # sendgrid, mailchimp
      t.string :api_key, null: false
      t.string :from_email, null: false
      t.string :from_name
      t.string :webhook_secret
      t.boolean :is_active, null: false, default: true
      t.boolean :is_default, null: false, default: false
      t.jsonb :settings, null: false, default: {} # provider-specific settings
      t.datetime :last_verified_at
      t.string :verification_status, default: "pending" # pending, verified, failed

      t.timestamps
    end

    add_index :email_providers, [:organization_id, :provider_type], unique: true
    add_index :email_providers, [:organization_id, :is_default]
  end
end
