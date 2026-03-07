class CreateTournamentRounds < ActiveRecord::Migration[8.0]
  def change
    create_table :tournament_rounds do |t|
      t.references :tournament, null: false, foreign_key: true
      t.integer :round_number, null: false, default: 1
      t.date :play_date, null: false
      t.integer :status, null: false, default: 0 # not_started, in_progress, completed

      t.timestamps
    end

    add_index :tournament_rounds, [:tournament_id, :round_number], unique: true
  end
end
