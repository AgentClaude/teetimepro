class AddBookingToFnbTabs < ActiveRecord::Migration[8.0]
  def change
    add_reference :fnb_tabs, :booking, null: true, foreign_key: true
    add_column :fnb_tabs, :turn_order, :boolean, null: false, default: false
    add_column :fnb_tabs, :delivery_hole, :integer, null: true
    add_column :fnb_tabs, :delivery_notes, :text, null: true

    add_index :fnb_tabs, [:booking_id, :turn_order], name: 'index_fnb_tabs_on_booking_and_turn_order'
  end
end
