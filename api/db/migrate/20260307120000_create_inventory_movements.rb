class CreateInventoryMovements < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_movements do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :pos_product, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.references :performed_by, null: false, foreign_key: { to_table: :users }
      
      t.string :movement_type, null: false
      t.integer :quantity, null: false
      t.text :notes
      
      # Polymorphic reference for linking to sales, adjustments, etc.
      t.references :reference, null: true, polymorphic: true, type: :string
      
      t.decimal :unit_cost_cents, precision: 10, scale: 2
      t.decimal :total_cost_cents, precision: 10, scale: 2
      
      t.timestamps
    end

    add_index :inventory_movements, [:organization_id, :pos_product_id], name: 'index_inventory_movements_on_org_and_product'
    add_index :inventory_movements, [:organization_id, :movement_type], name: 'index_inventory_movements_on_org_and_type'
    add_index :inventory_movements, [:organization_id, :course_id], name: 'index_inventory_movements_on_org_and_course'
    add_index :inventory_movements, [:reference_type, :reference_id], name: 'index_inventory_movements_on_reference'

    add_check_constraint :inventory_movements, 
      "movement_type IN ('receipt', 'sale', 'adjustment', 'transfer_in', 'transfer_out')", 
      name: 'inventory_movements_type_check'
  end
end