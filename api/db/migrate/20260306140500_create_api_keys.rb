class CreateApiKeys < ActiveRecord::Migration[8.0]
  def change
    create_table :api_keys do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :token, null: false
      t.boolean :active, default: true, null: false
      t.timestamp :last_used_at

      t.timestamps
    end

    add_index :api_keys, :token, unique: true
    add_index :api_keys, [:organization_id, :active]
  end
end