class CreateAccountingSyncs < ActiveRecord::Migration[8.0]
  def change
    create_table :accounting_syncs do |t|
      t.references :accounting_integration, null: false, foreign_key: { on_delete: :cascade }
      t.references :syncable, polymorphic: true, null: false # booking, payment, refund
      
      t.string :sync_type, null: false # 'invoice', 'payment', 'refund'
      t.integer :status, null: false, default: 0 # pending, in_progress, completed, failed
      t.string :external_id # ID in accounting system
      t.text :external_data # Full response from accounting system
      
      # Retry logic
      t.integer :retry_count, default: 0
      t.datetime :next_retry_at
      
      # Error tracking
      t.text :error_message
      t.datetime :error_at
      
      # Sync metadata
      t.datetime :started_at
      t.datetime :completed_at
      
      t.timestamps
    end

    add_index :accounting_syncs, [:accounting_integration_id, :sync_type]
    add_index :accounting_syncs, [:syncable_type, :syncable_id]
    add_index :accounting_syncs, :status
    add_index :accounting_syncs, :next_retry_at
  end
end
