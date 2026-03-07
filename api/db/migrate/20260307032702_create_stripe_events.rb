class CreateStripeEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :stripe_events, id: :bigint do |t|
      t.string :stripe_event_id, null: false
      t.string :event_type, null: false
      t.integer :status, null: false, default: 0
      t.jsonb :payload, null: false
      t.datetime :processed_at
      t.text :error_message

      t.timestamps
    end
    
    add_index :stripe_events, :stripe_event_id, unique: true
    add_index :stripe_events, :event_type
    add_index :stripe_events, :status
  end
end
