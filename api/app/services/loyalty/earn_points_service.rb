module Loyalty
  class EarnPointsService < ApplicationService
    attr_accessor :user, :organization, :points, :description, :source

    validates :user, presence: true
    validates :organization, presence: true
    validates :points, presence: true, numericality: { greater_than: 0 }
    validates :description, presence: true

    def call
      return validation_failure(self) if invalid?

      begin
        authorize_org_access!(user, organization)
        find_or_create_loyalty_account!
        award_points!
        success(
          account: @loyalty_account,
          transaction: @transaction,
          new_balance: @loyalty_account.points_balance,
          tier: @loyalty_account.tier
        )
      rescue => e
        failure(["Failed to earn points: #{e.message}"])
      end
    end

    private

    def find_or_create_loyalty_account!
      @loyalty_account = user.loyalty_account
      
      if @loyalty_account.nil?
        @loyalty_account = LoyaltyAccount.create!(
          user: user,
          organization: organization
        )
      end
    end

    def award_points!
      @loyalty_account.add_points!(
        points,
        description: description,
        source: source
      )
      
      # The transaction is created within add_points!
      @transaction = @loyalty_account.loyalty_transactions.order(:created_at).last
    end
  end
end