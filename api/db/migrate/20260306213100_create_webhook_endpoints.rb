class CreateWebhookEndpoints < ActiveRecord::Migration[8.0]
  def change
    create_table :webhook_endpoints do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :url, null: false
      t.string :secret, null: false
      t.json :events, null: false, default: []
      t.boolean :active, null: false, default: true
      t.text :description

      t.timestamps

      t.index [:organization_id, :url], unique: true
      t.index :active
    end

    add_check_constraint :webhook_endpoints, "url LIKE 'https://%'", name: 'webhook_endpoints_url_https_check'
  end
end
