module Loyalty
  class CreateRewardService < ApplicationService
    attr_accessor :organization, :name, :description, :points_cost, :reward_type, 
                  :discount_value, :is_active, :max_redemptions_per_user, :admin_user

    validates :organization, presence: true
    validates :name, presence: true
    validates :points_cost, presence: true, numericality: { greater_than: 0 }
    validates :reward_type, presence: true, inclusion: { in: LoyaltyReward.reward_types.keys }
    validates :admin_user, presence: true
    validates :discount_value, presence: true, numericality: { greater_than: 0 },
              if: -> { requires_discount_value? }

    def call
      return validation_failure(self) if invalid?

      begin
        authorize_org_access!(admin_user, organization)
        authorize_role!(admin_user, :manager)
        create_reward!
        success(reward: @reward)
      rescue => e
        failure(["Failed to create reward: #{e.message}"])
      end
    end

    private

    def requires_discount_value?
      %w[discount_percentage discount_fixed pro_shop_credit].include?(reward_type)
    end

    def create_reward!
      @reward = organization.loyalty_rewards.create!(
        name: name,
        description: description,
        points_cost: points_cost,
        reward_type: reward_type,
        discount_value: discount_value,
        is_active: is_active.nil? ? true : is_active,
        max_redemptions_per_user: max_redemptions_per_user
      )
    end
  end
end