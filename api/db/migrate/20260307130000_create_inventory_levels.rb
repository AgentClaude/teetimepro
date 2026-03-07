class CreateInventoryLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_levels do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :pos_product, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      
      t.integer :current_stock, null: false, default: 0
      t.integer :reserved_stock, null: false, default: 0
      t.integer :reorder_point, null: false, default: 0
      t.integer :reorder_quantity, null: false, default: 0
      
      # Cost tracking
      t.decimal :average_cost_cents, precision: 10, scale: 2
      t.decimal :last_cost_cents, precision: 10, scale: 2
      
      t.datetime :last_counted_at
      t.references :last_counted_by, null: true, foreign_key: { to_table: :users }
      
      t.timestamps
    end

    add_index :inventory_levels, [:organization_id, :pos_product_id, :course_id], 
              unique: true, name: 'index_inventory_levels_unique'
    add_index :inventory_levels, [:organization_id, :course_id], 
              name: 'index_inventory_levels_on_org_and_course'
    add_index :inventory_levels, [:organization_id], 
              where: 'current_stock <= reorder_point', 
              name: 'index_inventory_levels_low_stock'

    add_check_constraint :inventory_levels, 'current_stock >= 0', name: 'inventory_levels_current_stock_non_negative'
    add_check_constraint :inventory_levels, 'reserved_stock >= 0', name: 'inventory_levels_reserved_stock_non_negative'
    add_check_constraint :inventory_levels, 'reorder_point >= 0', name: 'inventory_levels_reorder_point_non_negative'
    add_check_constraint :inventory_levels, 'reorder_quantity >= 0', name: 'inventory_levels_reorder_quantity_non_negative'
  end
end