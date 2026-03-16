class CreateCourseGpsFeatures < ActiveRecord::Migration[8.0]
  def change
    create_table :course_gps_features do |t|
      t.references :course_hole, null: false, foreign_key: true
      t.integer :feature_type, null: false, default: 0
      t.string :name, null: false
      t.decimal :latitude, precision: 10, scale: 7, null: false
      t.decimal :longitude, precision: 10, scale: 7, null: false
      t.decimal :elevation_feet, precision: 8, scale: 2
      t.integer :distance_from_tee_yards
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :course_gps_features, [:course_hole_id, :feature_type]
  end
end
