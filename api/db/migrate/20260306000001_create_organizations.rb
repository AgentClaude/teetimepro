class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :stripe_account_id
      t.string :phone
      t.string :email
      t.string :address
      t.string :timezone, default: "UTC"
      t.string :logo_url
      t.jsonb :settings, default: {}

      t.timestamps
    end

    add_index :organizations, :slug, unique: true
  end
end
