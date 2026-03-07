class CreateFnbTabItems < ActiveRecord::Migration[8.0]
  def change
    create_table :fnb_tab_items, id: :bigint do |t|
      t.references :fnb_tab, null: false, foreign_key: true, type: :bigint
      t.string :name, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :unit_price_cents, null: false
      t.integer :total_cents, null: false
      t.string :category, null: false, default: 'food'
      t.text :notes
      t.references :added_by, null: false, foreign_key: { to_table: :users }, type: :bigint, comment: "Staff member who added the item"

      t.timestamps

      t.index [:fnb_tab_id, :created_at], name: 'index_fnb_tab_items_on_tab_and_created_at'
    end

    add_check_constraint :fnb_tab_items, "category IN ('food', 'beverage', 'other')", name: 'fnb_tab_items_category_check'
    add_check_constraint :fnb_tab_items, "quantity > 0", name: 'fnb_tab_items_quantity_positive'
    add_check_constraint :fnb_tab_items, "unit_price_cents >= 0", name: 'fnb_tab_items_unit_price_non_negative'
    add_check_constraint :fnb_tab_items, "total_cents >= 0", name: 'fnb_tab_items_total_cents_non_negative'
  end
end
