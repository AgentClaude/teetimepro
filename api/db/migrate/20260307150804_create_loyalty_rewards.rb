class CreateLoyaltyRewards < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      create_table :loyalty_rewards do |t|
        t.references :organization, null: false, foreign_key: true
        t.string :name, null: false
        t.text :description
        t.integer :points_cost, null: false
        t.integer :reward_type, null: false
        t.integer :discount_value
        t.boolean :is_active, default: true, null: false
        t.integer :max_redemptions_per_user

        t.timestamps
      end

      # organization_id index already created by t.references
      add_index :loyalty_rewards, :is_active
      add_index :loyalty_rewards, :reward_type
    end
  end
end
