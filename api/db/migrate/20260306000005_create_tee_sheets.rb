class CreateTeeSheets < ActiveRecord::Migration[8.0]
  def change
    create_table :tee_sheets do |t|
      t.references :course, null: false, foreign_key: { on_delete: :cascade }
      t.date :date, null: false
      t.text :notes
      t.datetime :generated_at

      t.timestamps
    end

    add_index :tee_sheets, %i[course_id date], unique: true
  end
end
