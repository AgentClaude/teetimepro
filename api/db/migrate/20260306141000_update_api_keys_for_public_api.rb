class UpdateApiKeysForPublicApi < ActiveRecord::Migration[8.0]
  def change
    # Remove old token field and index
    remove_index :api_keys, :token
    remove_column :api_keys, :token, :string

    # Add new fields according to specification
    add_column :api_keys, :key_digest, :string, null: false
    add_column :api_keys, :prefix, :string, null: false, limit: 8
    add_column :api_keys, :scopes, :jsonb, null: false, default: []
    add_column :api_keys, :rate_limit_tier, :string, null: false, default: 'standard'
    add_column :api_keys, :expires_at, :timestamp

    # Add new indexes
    add_index :api_keys, :key_digest, unique: true
    add_index :api_keys, :prefix
    add_index :api_keys, :scopes, using: :gin
    add_index :api_keys, :rate_limit_tier
  end
end