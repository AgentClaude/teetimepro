class CreateTournamentResults < ActiveRecord::Migration[8.0]
  def change
    create_table :tournament_results do |t|
      t.references :tournament, null: false, foreign_key: true
      t.references :tournament_entry, null: false, foreign_key: true
      t.integer :position, null: false
      t.integer :total_strokes, null: false
      t.integer :total_to_par, null: false
      t.boolean :tied, null: false, default: false
      t.boolean :prize_awarded, null: false, default: false
      t.datetime :finalized_at

      t.timestamps
    end

    add_index :tournament_results, [:tournament_id, :position]
    add_index :tournament_results, [:tournament_id, :tournament_entry_id], unique: true
    add_index :tournament_results, :position
  end
end