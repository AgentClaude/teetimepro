# frozen_string_literal: true

class CreateDeviceTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :device_tokens, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.string :token, null: false
      t.string :platform, null: false # ios, android
      t.string :device_id # unique device identifier for dedup
      t.boolean :active, null: false, default: true
      t.datetime :last_used_at
      t.timestamps
    end

    add_index :device_tokens, :token, unique: true
    add_index :device_tokens, [:user_id, :platform]
    add_index :device_tokens, :active
  end
end
