class CreateLoyaltyRedemptions < ActiveRecord::Migration[8.0]
  def change
    create_table :loyalty_redemptions do |t|
      t.references :loyalty_account, null: false, foreign_key: true
      t.references :loyalty_reward, null: false, foreign_key: true
      t.references :booking, null: true, foreign_key: true
      t.integer :status, default: 0, null: false # pending: 0, applied: 1, expired: 2, cancelled: 3
      t.string :code, null: false
      t.datetime :expires_at

      t.timestamps
    end

    # loyalty_account_id, loyalty_reward_id, booking_id indexes already created by t.references
    add_index :loyalty_redemptions, :status
    add_index :loyalty_redemptions, :code, unique: true
    add_index :loyalty_redemptions, :expires_at
  end
end