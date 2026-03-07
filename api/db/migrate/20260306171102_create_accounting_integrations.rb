class CreateAccountingIntegrations < ActiveRecord::Migration[8.0]
  def change
    create_table :accounting_integrations do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      
      t.string :provider, null: false # 'quickbooks' or 'xero'
      t.integer :status, null: false, default: 0 # disconnected, connected, error
      
      # OAuth credentials (encrypted)
      t.text :encrypted_access_token
      t.text :encrypted_refresh_token
      t.text :encrypted_realm_id # QuickBooks company ID
      t.text :encrypted_tenant_id # Xero tenant ID
      
      # Connection info
      t.string :company_name
      t.string :country_code
      t.datetime :connected_at
      t.datetime :last_sync_at
      
      # Account mapping configuration
      t.json :account_mapping, default: {} # Maps tee time categories to chart of accounts
      t.json :settings, default: {} # Provider-specific settings
      
      # Error tracking
      t.text :last_error_message
      t.datetime :last_error_at
      
      t.timestamps
    end

    add_index :accounting_integrations, [:organization_id, :provider], unique: true
    add_index :accounting_integrations, :status
  end
end