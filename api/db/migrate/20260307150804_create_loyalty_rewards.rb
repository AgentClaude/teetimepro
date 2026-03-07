class CreateLoyaltyRewards < ActiveRecord::Migration[8.0]
  def change
    create_table :loyalty_rewards do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :points_cost, null: false
      t.integer :reward_type, null: false # discount_percentage: 0, discount_fixed: 1, free_round: 2, pro_shop_credit: 3
      t.integer :discount_value # in cents
      t.boolean :is_active, default: true, null: false
      t.integer :max_redemptions_per_user # nullable for unlimited

      t.timestamps
    end

    add_index :loyalty_rewards, :organization_id
    add_index :loyalty_rewards, :is_active
    add_index :loyalty_rewards, :reward_type
  end
end