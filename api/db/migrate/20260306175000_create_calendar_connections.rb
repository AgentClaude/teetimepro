class CreateCalendarConnections < ActiveRecord::Migration[8.0]
  def change
    create_table :calendar_connections do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false # 'google', 'apple', etc.
      t.text :access_token
      t.text :refresh_token
      t.datetime :token_expires_at
      t.boolean :enabled, default: true, null: false
      t.string :calendar_id
      t.string :calendar_name

      t.timestamps
    end

    add_index :calendar_connections, [:user_id, :provider], unique: true
    add_index :calendar_connections, :provider
    add_index :calendar_connections, :enabled
  end
end