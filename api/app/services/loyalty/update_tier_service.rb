module Loyalty
  class UpdateTierService < ApplicationService
    attr_accessor :user, :organization

    validates :user, presence: true
    validates :organization, presence: true

    def call
      return validation_failure(self) if invalid?

      begin
        authorize_org_access!(user, organization)
        find_loyalty_account!
        find_loyalty_program!
        update_tier!
        success(
          account: @loyalty_account,
          old_tier: @old_tier,
          new_tier: @loyalty_account.tier,
          tier_changed: @tier_changed
        )
      rescue => e
        failure(["Failed to update tier: #{e.message}"])
      end
    end

    private

    def find_loyalty_account!
      @loyalty_account = user.loyalty_account
      raise "User does not have a loyalty account" unless @loyalty_account
    end

    def find_loyalty_program!
      @loyalty_program = organization.loyalty_programs.active.first
      raise "No active loyalty program found" unless @loyalty_program
    end

    def update_tier!
      @old_tier = @loyalty_account.tier
      new_tier = @loyalty_program.tier_for_points(@loyalty_account.lifetime_points)
      
      @tier_changed = @old_tier != new_tier
      
      if @tier_changed
        @loyalty_account.update!(tier: new_tier)
        
        # Create a transaction to record the tier change
        @loyalty_account.loyalty_transactions.create!(
          transaction_type: :adjust,
          points: 0,
          description: "Tier updated from #{@old_tier.humanize} to #{new_tier.humanize}",
          balance_after: @loyalty_account.points_balance,
          source: @loyalty_program
        )
      end
    end
  end
end