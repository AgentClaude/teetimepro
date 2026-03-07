class CreatePosProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :pos_products do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.string :name, null: false
      t.string :sku, null: false
      t.string :barcode
      t.integer :price_cents, null: false
      t.string :category, null: false, default: 'other'
      t.text :description
      t.boolean :active, null: false, default: true
      t.integer :stock_quantity
      t.boolean :track_inventory, null: false, default: false
      t.timestamps
    end

    add_index :pos_products, [:organization_id, :sku], unique: true, name: 'index_pos_products_on_org_and_sku'
    add_index :pos_products, [:organization_id, :barcode], unique: true, where: 'barcode IS NOT NULL', name: 'index_pos_products_on_org_and_barcode'
    add_index :pos_products, [:organization_id, :category], name: 'index_pos_products_on_org_and_category'
    add_index :pos_products, [:organization_id, :active], name: 'index_pos_products_on_org_and_active'

    add_check_constraint :pos_products, 'price_cents >= 0', name: 'pos_products_price_non_negative'
    add_check_constraint :pos_products, "category IN ('food', 'beverage', 'apparel', 'equipment', 'rental', 'other')", name: 'pos_products_category_check'
  end
end
