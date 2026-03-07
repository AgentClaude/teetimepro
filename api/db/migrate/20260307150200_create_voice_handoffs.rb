class CreateVoiceHandoffs < ActiveRecord::Migration[7.1]
  def change
    create_table :voice_handoffs do |t|
      t.references :organization, null: false, foreign_key: true, type: :bigint, index: true
      t.references :voice_call_log, null: true, foreign_key: true, type: :bigint, index: true
      
      t.string :call_sid, null: false
      t.string :caller_phone, null: false
      t.string :caller_name
      t.string :reason, null: false
      t.text :reason_detail
      t.string :status, null: false, default: 'pending'
      t.string :transfer_to, null: false
      t.string :staff_name
      t.integer :wait_seconds
      t.text :resolution_notes
      
      t.datetime :started_at, null: false
      t.datetime :connected_at
      t.datetime :completed_at

      t.timestamps
    end

    # Composite indexes for common queries
    add_index :voice_handoffs, [:organization_id, :status]
    add_index :voice_handoffs, [:organization_id, :started_at]
    add_index :voice_handoffs, :call_sid, unique: true
  end
end