class CreateMemberAccountCharges < ActiveRecord::Migration[8.0]
  def change
    create_table :member_account_charges, id: :bigint do |t|
      t.references :organization, null: false, foreign_key: true, type: :bigint
      t.references :membership, null: false, foreign_key: true, type: :bigint
      t.references :charged_by, null: false, foreign_key: { to_table: :users }, type: :bigint
      t.references :fnb_tab, null: true, foreign_key: true, type: :bigint
      t.references :booking, null: true, foreign_key: true, type: :bigint

      t.string :charge_type, null: false, default: 'fnb'
      t.string :status, null: false, default: 'pending'
      t.integer :amount_cents, null: false
      t.string :amount_currency, default: 'USD', null: false
      t.text :description
      t.text :notes
      t.datetime :posted_at
      t.datetime :voided_at

      t.timestamps

      t.index [:organization_id, :membership_id], name: 'idx_member_charges_org_membership'
      t.index [:membership_id, :status], name: 'idx_member_charges_membership_status'
      t.index [:organization_id, :created_at], name: 'idx_member_charges_org_created'
      t.index :charge_type
      t.index :status
    end

    add_check_constraint :member_account_charges,
      "charge_type IN ('fnb', 'booking', 'pro_shop', 'dues', 'other')",
      name: 'member_account_charges_type_check'

    add_check_constraint :member_account_charges,
      "status IN ('pending', 'posted', 'voided', 'paid')",
      name: 'member_account_charges_status_check'

    add_check_constraint :member_account_charges,
      "amount_cents > 0",
      name: 'member_account_charges_amount_positive'

    # Add balance tracking columns to memberships
    add_column :memberships, :account_balance_cents, :integer, null: false, default: 0
    add_column :memberships, :credit_limit_cents, :integer, null: false, default: 500_000 # $5,000 default
  end
end
