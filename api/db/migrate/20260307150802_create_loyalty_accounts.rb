class CreateLoyaltyAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :loyalty_accounts do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :points_balance, default: 0, null: false
      t.integer :lifetime_points, default: 0, null: false
      t.integer :tier, default: 0, null: false # bronze: 0, silver: 1, gold: 2, platinum: 3

      t.timestamps
    end

    add_index :loyalty_accounts, [:organization_id, :user_id], unique: true
    # user_id index already created by t.references
  end
end