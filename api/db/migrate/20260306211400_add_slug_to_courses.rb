class AddSlugToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :slug, :string
    add_index :courses, :slug, unique: true

    # Generate slugs for existing courses
    reversible do |dir|
      dir.up do
        Course.reset_column_information
        Course.find_each do |course|
          course.update!(slug: course.name.parameterize)
        end
        
        change_column_null :courses, :slug, false
      end
    end
  end
end