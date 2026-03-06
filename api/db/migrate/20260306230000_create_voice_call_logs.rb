class CreateVoiceCallLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :voice_call_logs do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.references :course, null: true, foreign_key: { on_delete: :nullify }
      t.string :call_sid
      t.string :channel, null: false, default: "browser" # browser, twilio
      t.string :caller_phone
      t.string :caller_name
      t.string :status, null: false, default: "in_progress" # in_progress, completed, error
      t.integer :duration_seconds
      t.jsonb :transcript, null: false, default: [] # array of event objects
      t.jsonb :summary, null: false, default: {} # extracted stats
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.timestamps
    end

    add_index :voice_call_logs, :call_sid, unique: true, where: "call_sid IS NOT NULL"
    add_index :voice_call_logs, [:organization_id, :started_at]
    add_index :voice_call_logs, :channel
    add_index :voice_call_logs, :status
  end
end
