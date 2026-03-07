module Loyalty
  class AdjustPointsService < ApplicationService
    attr_accessor :user, :organization, :points_adjustment, :reason, :admin_user

    validates :user, presence: true
    validates :organization, presence: true
    validates :points_adjustment, presence: true
    validates :reason, presence: true
    validates :admin_user, presence: true

    def call
      return validation_failure(self) if invalid?

      begin
        authorize_org_access!(user, organization)
        authorize_org_access!(admin_user, organization)
        authorize_role!(admin_user, :manager)
        find_loyalty_account!
        adjust_points!
        success(
          account: @loyalty_account,
          transaction: @transaction,
          new_balance: @loyalty_account.points_balance,
          tier: @loyalty_account.tier
        )
      rescue => e
        failure(["Failed to adjust points: #{e.message}"])
      end
    end

    private

    def find_loyalty_account!
      @loyalty_account = user.loyalty_account
      
      if @loyalty_account.nil?
        @loyalty_account = LoyaltyAccount.create!(
          user: user,
          organization: organization
        )
      end
    end

    def adjust_points!
      description = "Manual adjustment by #{admin_user.full_name}: #{reason}"
      
      @loyalty_account.adjust_points!(
        points_adjustment,
        description: description,
        source: admin_user
      )
      
      # The transaction is created within adjust_points!
      @transaction = @loyalty_account.loyalty_transactions.order(:created_at).last
    end
  end
end