class CreateCallTranscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :call_transcriptions, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid, index: true
      t.references :call_recording, null: false, foreign_key: true, type: :uuid, index: true
      t.references :voice_call_log, null: true, foreign_key: true, type: :uuid, index: true
      t.text :transcription_text, null: false
      t.decimal :confidence_score, precision: 3, scale: 2, null: false
      t.string :language, null: false, default: 'en'
      t.string :provider, null: false, default: 'deepgram'
      t.jsonb :raw_response, null: true, default: {}
      t.string :status, null: false, default: 'pending'
      t.integer :word_count, null: false, default: 0
      t.integer :duration_seconds, null: false

      t.timestamps
    end

    add_index :call_transcriptions, [:organization_id, :created_at]
    add_index :call_transcriptions, [:organization_id, :status]
    add_index :call_transcriptions, :transcription_text, using: :gin
  end
end