class CreateRoundsAndHandicapRevisions < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      create_table :rounds do |t|
        t.references :golfer_profile, null: false, foreign_key: { on_delete: :cascade }
        t.references :course, null: true, foreign_key: { on_delete: :nullify }
        t.string :course_name, null: false
        t.date :played_on, null: false
        t.integer :score, null: false
        t.integer :holes_played, null: false, default: 18
        t.decimal :course_rating, precision: 4, scale: 1
        t.integer :slope_rating
        t.decimal :differential, precision: 5, scale: 1
        t.string :tee_color
        t.text :notes
        t.integer :putts
        t.integer :fairways_hit
        t.integer :greens_in_regulation
        t.datetime :created_at, null: false
        t.datetime :updated_at, null: false
      end

      add_index :rounds, [:golfer_profile_id, :played_on]
      add_index :rounds, :played_on

      create_table :handicap_revisions do |t|
        t.references :golfer_profile, null: false, foreign_key: { on_delete: :cascade }
        t.decimal :handicap_index, precision: 4, scale: 1, null: false
        t.decimal :previous_index, precision: 4, scale: 1
        t.integer :rounds_used, null: false, default: 0
        t.date :effective_date, null: false
        t.string :source, null: false, default: "calculated"
        t.text :notes
        t.datetime :created_at, null: false
        t.datetime :updated_at, null: false
      end

      add_index :handicap_revisions, [:golfer_profile_id, :effective_date]

      # Add additional fields to golfer_profiles
      add_column :golfer_profiles, :total_rounds, :integer, default: 0, null: false
      add_column :golfer_profiles, :best_score, :integer
      add_column :golfer_profiles, :average_score, :decimal, precision: 5, scale: 1
      add_column :golfer_profiles, :last_played_on, :date
      add_column :golfer_profiles, :handicap_updated_at, :datetime
    end
  end
end
