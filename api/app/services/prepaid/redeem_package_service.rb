# frozen_string_literal: true

module Prepaid
  class RedeemPackageService < ApplicationService
    class InsufficientBalanceError < StandardError; end
    attr_accessor :prepaid_purchase, :booking, :user, :value_cents

    validates :prepaid_purchase, :booking, :user, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Package is not usable"]) unless prepaid_purchase.usable?
      return failure(["Package cannot be used for this booking"]) unless prepaid_purchase.can_redeem_for_booking?(booking)
      return failure(["User does not own this package"]) unless authorized_user?

      ActiveRecord::Base.transaction do
        redemption = create_redemption!
        update_purchase!
        check_fully_redeemed!

        success(redemption: redemption, purchase: prepaid_purchase.reload)
      end
    rescue InsufficientBalanceError => e
      failure([e.message])
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end

    private

    def authorized_user?
      prepaid_purchase.user_id == user.id ||
        (prepaid_purchase.transferable? && prepaid_purchase.organization_id == user.organization_id)
    end

    def create_redemption!
      if prepaid_purchase.round_pack? || prepaid_purchase.time_pass?
        PrepaidRedemption.create!(
          prepaid_purchase: prepaid_purchase,
          booking: booking,
          user: user,
          redemption_type: :round,
          rounds_used: 1
        )
      elsif prepaid_purchase.value_card?
        amount = value_cents || booking.total_cents
        amount = [amount, prepaid_purchase.balance_cents].min

        raise InsufficientBalanceError, "Insufficient balance" if amount <= 0

        PrepaidRedemption.create!(
          prepaid_purchase: prepaid_purchase,
          booking: booking,
          user: user,
          redemption_type: :value,
          value_cents: amount
        )
      end
    end

    def update_purchase!
      if prepaid_purchase.round_pack?
        prepaid_purchase.decrement!(:rounds_remaining)
      elsif prepaid_purchase.value_card?
        redemption_amount = prepaid_purchase.prepaid_redemptions.last.value_cents
        prepaid_purchase.update!(balance_cents: prepaid_purchase.balance_cents - redemption_amount)
      end
      # time_pass doesn't decrement anything
    end

    def check_fully_redeemed!
      if prepaid_purchase.round_pack? && prepaid_purchase.rounds_remaining.zero?
        prepaid_purchase.update!(status: :fully_redeemed)
      elsif prepaid_purchase.value_card? && prepaid_purchase.balance_cents.zero?
        prepaid_purchase.update!(status: :fully_redeemed)
      end
    end
  end
end
