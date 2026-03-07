class CreateCallRecordings < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      create_table :call_recordings do |t|
        t.references :organization, null: false, foreign_key: true, index: true
        t.references :voice_call_log, null: true, foreign_key: true, index: true
        t.string :call_sid, null: false, index: true
        t.string :recording_sid, null: false, index: { unique: true }
        t.string :recording_url, null: false
        t.integer :duration_seconds, null: false
        t.string :status, null: false, default: 'pending'
        t.bigint :file_size_bytes, null: true
        t.string :format, null: false, default: 'wav'

        t.timestamps
      end

      add_index :call_recordings, [:organization_id, :created_at]
      add_index :call_recordings, [:organization_id, :status]
    end
  end
end
