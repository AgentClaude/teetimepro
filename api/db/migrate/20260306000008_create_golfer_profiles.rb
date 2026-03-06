class CreateGolferProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :golfer_profiles do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.decimal :handicap_index, precision: 4, scale: 1
      t.string :home_course
      t.string :preferred_tee

      t.timestamps
    end
  end
end
