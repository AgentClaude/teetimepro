class CreateTournamentScores < ActiveRecord::Migration[8.0]
  def change
    create_table :tournament_scores do |t|
      t.references :tournament_round, null: false, foreign_key: true
      t.references :tournament_entry, null: false, foreign_key: true
      t.integer :hole_number, null: false
      t.integer :strokes, null: false
      t.integer :par, null: false
      t.integer :putts
      t.boolean :fairway_hit
      t.boolean :green_in_regulation

      t.timestamps
    end

    add_index :tournament_scores,
              [:tournament_round_id, :tournament_entry_id, :hole_number],
              unique: true,
              name: "idx_scores_on_round_entry_hole"
  end
end
