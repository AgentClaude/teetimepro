class CreateApiKeys < ActiveRecord::Migration[8.0]
  def change
    create_table :api_keys do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :key_digest, null: false
      t.string :prefix, null: false, limit: 8
      t.jsonb :scopes, null: false, default: ['read']
      t.string :rate_limit_tier, null: false, default: 'standard'
      t.boolean :active, default: true, null: false
      t.timestamp :expires_at
      t.timestamp :last_used_at

      t.timestamps
    end

    add_index :api_keys, :key_digest, unique: true
    add_index :api_keys, :prefix
    add_index :api_keys, [:organization_id, :active]
    add_index :api_keys, :scopes, using: :gin
    add_index :api_keys, :rate_limit_tier
  end
end
