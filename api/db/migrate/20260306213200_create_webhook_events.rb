class CreateWebhookEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :webhook_events do |t|
      t.references :webhook_endpoint, null: false, foreign_key: true
      t.string :event_type, null: false
      t.json :payload, null: false, default: {}
      t.integer :status, null: false, default: 0
      t.integer :attempts, null: false, default: 0
      t.datetime :last_attempted_at
      t.datetime :delivered_at
      t.integer :response_code
      t.text :response_body

      t.timestamps

      t.index [:webhook_endpoint_id, :created_at]
      t.index [:status, :created_at]
      t.index :event_type
      t.index :last_attempted_at
    end

    add_check_constraint :webhook_events, "attempts >= 0", name: 'webhook_events_attempts_positive_check'
    add_check_constraint :webhook_events, "response_code BETWEEN 100 AND 599", name: 'webhook_events_response_code_valid_check'
  end
end
