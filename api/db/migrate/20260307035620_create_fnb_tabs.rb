class CreateFnbTabs < ActiveRecord::Migration[8.0]
  def change
    create_table :fnb_tabs, id: :bigint do |t|
      t.references :organization, null: false, foreign_key: true, type: :bigint
      t.references :course, null: false, foreign_key: true, type: :bigint
      t.references :user, null: false, foreign_key: true, type: :bigint, comment: "Server who opened the tab"
      t.string :golfer_name, null: false
      t.string :status, null: false, default: 'open'
      t.integer :total_cents, null: false, default: 0
      t.datetime :opened_at, null: false
      t.datetime :closed_at

      t.timestamps

      t.index [:organization_id, :status], name: 'index_fnb_tabs_on_org_and_status'
      t.index [:course_id, :status], name: 'index_fnb_tabs_on_course_and_status' 
      t.index [:user_id, :opened_at], name: 'index_fnb_tabs_on_user_and_opened_at'
      t.index :opened_at
    end

    add_check_constraint :fnb_tabs, "status IN ('open', 'closed', 'merged')", name: 'fnb_tabs_status_check'
    add_check_constraint :fnb_tabs, "total_cents >= 0", name: 'fnb_tabs_total_cents_non_negative'
  end
end
