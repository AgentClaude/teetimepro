class CreateTournamentEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :tournament_entries do |t|
      t.references :tournament, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :payment, null: true, foreign_key: { on_delete: :nullify }

      t.integer :status, null: false, default: 0 # registered, confirmed, withdrawn, disqualified
      t.string :team_name
      t.decimal :handicap_index, precision: 4, scale: 1
      t.integer :starting_hole # shotgun start support
      t.time :tee_time # assigned tee time for the tournament
      t.json :metadata, default: {} # flexible extra data

      t.timestamps
    end

    add_index :tournament_entries, [:tournament_id, :user_id], unique: true
    add_index :tournament_entries, :status
  end
end
