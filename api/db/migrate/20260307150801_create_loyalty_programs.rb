class CreateLoyaltyPrograms < ActiveRecord::Migration[8.0]
  def change
    create_table :loyalty_programs do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :points_per_dollar, default: 10, null: false
      t.boolean :is_active, default: true, null: false
      t.jsonb :tier_thresholds, default: {
        "silver" => 500,
        "gold" => 2000,
        "platinum" => 5000
      }

      t.timestamps
    end

    add_index :loyalty_programs, :organization_id
  end
end