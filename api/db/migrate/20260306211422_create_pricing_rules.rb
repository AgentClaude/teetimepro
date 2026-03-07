class CreatePricingRules < ActiveRecord::Migration[7.0]
  def change
    create_table :pricing_rules do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :course, null: true, foreign_key: true
      t.string :name, null: false
      t.string :rule_type, null: false
      t.jsonb :conditions, default: {}
      t.decimal :multiplier, precision: 10, scale: 4, default: 1.0
      t.integer :flat_adjustment_cents, default: 0
      t.integer :priority, default: 0
      t.boolean :active, default: true
      t.date :start_date
      t.date :end_date
      t.timestamps
    end

    add_index :pricing_rules, [:organization_id, :course_id]
    add_index :pricing_rules, [:organization_id, :active]
    add_index :pricing_rules, [:organization_id, :rule_type]
    add_index :pricing_rules, :priority
  end
end