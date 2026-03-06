class CreateTournaments < ActiveRecord::Migration[8.0]
  def change
    create_table :tournaments do |t|
      t.references :course, null: false, foreign_key: { on_delete: :cascade }
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.string :name, null: false
      t.text :description
      t.integer :format, null: false, default: 0 # stroke, match, scramble, best_ball
      t.integer :status, null: false, default: 0 # draft, registration_open, registration_closed, in_progress, completed, cancelled

      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :max_participants
      t.integer :min_participants, default: 2
      t.integer :team_size, default: 1 # 1 for individual, 2+ for team formats

      t.integer :entry_fee_cents, default: 0
      t.string :entry_fee_currency, default: "USD"

      t.integer :holes, default: 18 # 9 or 18
      t.boolean :handicap_enabled, default: true
      t.decimal :max_handicap, precision: 4, scale: 1 # e.g., 36.0
      t.json :rules, default: {} # flexible rules storage (tiebreakers, local rules, etc.)
      t.json :prize_structure, default: {} # payout/prize info

      t.datetime :registration_opens_at
      t.datetime :registration_closes_at

      t.timestamps
    end

    add_index :tournaments, [:organization_id, :start_date]
    add_index :tournaments, [:course_id, :start_date]
    add_index :tournaments, :status
  end
end
