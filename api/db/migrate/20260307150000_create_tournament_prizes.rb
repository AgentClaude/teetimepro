class CreateTournamentPrizes < ActiveRecord::Migration[8.0]
  def change
    create_table :tournament_prizes do |t|
      t.references :tournament, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :prize_type, null: false
      t.text :description, null: false
      t.integer :amount_cents, null: false, default: 0
      t.references :awarded_to, null: true, foreign_key: { to_table: :tournament_entries }

      t.timestamps
    end

    add_index :tournament_prizes, [:tournament_id, :position], unique: true
    add_index :tournament_prizes, :prize_type
  end
end