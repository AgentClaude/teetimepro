class CreateScorecardsAndHoleScores < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      create_table :scorecards do |t|
        t.references :golfer_profile, null: false, foreign_key: { on_delete: :cascade }
        t.references :course, null: false, foreign_key: { on_delete: :cascade }
        t.references :booking, null: true, foreign_key: { on_delete: :nullify }
        t.references :round, null: true, foreign_key: { on_delete: :nullify }
        t.date :played_on, null: false
        t.integer :holes_played, null: false, default: 18
        t.integer :total_strokes
        t.integer :total_putts
        t.integer :total_fairways_hit
        t.integer :total_greens_in_regulation
        t.integer :total_penalties
        t.integer :front_nine_strokes
        t.integer :back_nine_strokes
        t.integer :score_to_par
        t.string :status, null: false, default: "in_progress"
        t.string :tee_color
        t.decimal :course_rating, precision: 4, scale: 1
        t.integer :slope_rating
        t.text :notes
        t.datetime :started_at
        t.datetime :completed_at
        t.datetime :created_at, null: false
        t.datetime :updated_at, null: false
      end

      add_index :scorecards, [:golfer_profile_id, :played_on]
      add_index :scorecards, :status

      create_table :hole_scores do |t|
        t.references :scorecard, null: false, foreign_key: { on_delete: :cascade }
        t.integer :hole_number, null: false
        t.integer :par, null: false
        t.integer :strokes
        t.integer :putts
        t.boolean :fairway_hit
        t.boolean :green_in_regulation
        t.integer :penalties, default: 0
        t.integer :score_to_par
        t.text :notes
        t.datetime :created_at, null: false
        t.datetime :updated_at, null: false
      end

      add_index :hole_scores, [:scorecard_id, :hole_number], unique: true
      add_index :hole_scores, :hole_number

      # Add course hole configuration
      create_table :course_holes do |t|
        t.references :course, null: false, foreign_key: { on_delete: :cascade }
        t.integer :hole_number, null: false
        t.integer :par, null: false
        t.integer :yardage
        t.integer :handicap_index
        t.datetime :created_at, null: false
        t.datetime :updated_at, null: false
      end

      add_index :course_holes, [:course_id, :hole_number], unique: true
    end
  end
end
