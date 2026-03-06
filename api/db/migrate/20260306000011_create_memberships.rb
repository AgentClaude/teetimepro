class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.integer :tier, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.integer :price_cents
      t.string :price_currency, default: "USD"
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :auto_renew, default: true, null: false

      t.timestamps
    end

    add_index :memberships, %i[organization_id user_id], unique: true
    add_index :memberships, :status
  end
end
