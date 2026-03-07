# frozen_string_literal: true

class CreateWaitlistEntries < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      create_table :waitlist_entries do |t|
        t.references :user, null: false, foreign_key: true
        t.references :tee_time, null: false, foreign_key: true
        t.references :organization, null: false, foreign_key: true
        t.integer :players_requested, null: false, default: 1
        t.integer :status, null: false, default: 0
        t.datetime :notified_at
        t.datetime :expired_at

        t.timestamps
      end

      add_index :waitlist_entries, [:user_id, :tee_time_id], unique: true,
                name: "index_waitlist_entries_on_user_and_tee_time"
      add_index :waitlist_entries, [:tee_time_id, :status],
                name: "index_waitlist_entries_on_tee_time_and_status"
    end
  end
end
