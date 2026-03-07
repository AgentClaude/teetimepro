class CreateEmailProviders < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      create_table :email_providers do |t|
        t.references :organization, null: false, foreign_key: true
        t.string :provider_type, null: false
        t.string :api_key, null: false
        t.string :from_email, null: false
        t.string :from_name
        t.string :webhook_secret
        t.boolean :is_active, null: false, default: true
        t.boolean :is_default, null: false, default: false
        t.jsonb :settings, null: false, default: {}
        t.datetime :last_verified_at
        t.string :verification_status, default: "pending"

        t.timestamps
      end

      add_index :email_providers, [:organization_id, :provider_type], unique: true
      add_index :email_providers, [:organization_id, :is_default]
    end
  end
end
