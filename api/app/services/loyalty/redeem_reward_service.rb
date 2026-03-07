module Loyalty
  class RedeemRewardService < ApplicationService
    attr_accessor :user, :organization, :reward_id

    validates :user, presence: true
    validates :organization, presence: true
    validates :reward_id, presence: true

    def call
      return validation_failure(self) if invalid?

      begin
        authorize_org_access!(user, organization)
        find_reward!
        find_loyalty_account!
        validate_redemption!
        process_redemption!
        success(
          redemption: @redemption,
          account: @loyalty_account,
          new_balance: @loyalty_account.points_balance
        )
      rescue => e
        failure(["Failed to redeem reward: #{e.message}"])
      end
    end

    private

    def find_reward!
      @reward = organization.loyalty_rewards.active.find(reward_id)
    end

    def find_loyalty_account!
      @loyalty_account = user.loyalty_account
      raise "User does not have a loyalty account" unless @loyalty_account
    end

    def validate_redemption!
      unless @loyalty_account.can_afford?(@reward.points_cost)
        raise "Insufficient points. Need #{@reward.points_cost}, have #{@loyalty_account.points_balance}"
      end

      unless @reward.can_be_redeemed_by?(user)
        raise "Reward redemption limit reached"
      end
    end

    def process_redemption!
      LoyaltyAccount.transaction do
        # Deduct points from account
        @loyalty_account.deduct_points!(
          @reward.points_cost,
          description: "Redeemed reward: #{@reward.name}",
          source: @reward
        )

        # Create redemption record
        @redemption = LoyaltyRedemption.create!(
          loyalty_account: @loyalty_account,
          loyalty_reward: @reward
        )
      end
    end
  end
end