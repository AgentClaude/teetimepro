class CreateLoyaltyTransactions < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      create_table :loyalty_transactions do |t|
        t.references :loyalty_account, null: false, foreign_key: true
        t.references :source, null: true, polymorphic: true
        t.integer :transaction_type, null: false
        t.integer :points, null: false
        t.string :description, null: false
        t.integer :balance_after, null: false

        t.timestamps
      end

      # loyalty_account_id and [source_type, source_id] indexes created by t.references
      add_index :loyalty_transactions, :transaction_type
      add_index :loyalty_transactions, :created_at
    end
  end
end
