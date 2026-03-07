class CreateLoyaltyTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :loyalty_transactions do |t|
      t.references :loyalty_account, null: false, foreign_key: true
      t.references :source, null: true, polymorphic: true
      t.integer :transaction_type, null: false # earn: 0, redeem: 1, adjust: 2, expire: 3
      t.integer :points, null: false # can be negative for redemptions
      t.string :description, null: false
      t.integer :balance_after, null: false

      t.timestamps
    end

    add_index :loyalty_transactions, :loyalty_account_id
    add_index :loyalty_transactions, [:source_type, :source_id]
    add_index :loyalty_transactions, :transaction_type
    add_index :loyalty_transactions, :created_at
  end
end