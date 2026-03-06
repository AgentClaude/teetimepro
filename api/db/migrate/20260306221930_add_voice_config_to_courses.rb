class AddVoiceConfigToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :voice_config, :jsonb, default: {}, null: false
  end
end
