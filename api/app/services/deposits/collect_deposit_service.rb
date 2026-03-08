# frozen_string_literal: true

module Deposits
  class CollectDepositService < ApplicationService
    attr_accessor :booking, :amount_cents, :payment_method, :provider_transaction_id

    validates :booking, :amount_cents, presence: true
    validates :amount_cents, numericality: { greater_than: 0 }

    def call
      return validation_failure(self) unless valid?
      return failure(["Booking already has a deposit"]) if booking.deposit_cents.present? && booking.deposit_cents.positive?
      return failure(["Deposit exceeds booking total"]) if amount_cents > booking.total_cents

      ActiveRecord::Base.transaction do
        # Create a payment record for the deposit
        payment = Payment.create!(
          booking: booking,
          organization: booking.organization,
          user: booking.user,
          amount_cents: amount_cents,
          status: :completed,
          payment_method: payment_method || :card,
          provider: provider_transaction_id.present? ? :stripe : :manual,
          provider_transaction_id: provider_transaction_id,
          metadata: { type: "deposit" }
        )

        booking.update!(
          deposit_cents: amount_cents,
          deposit_paid_at: Time.current
        )

        success(payment: payment, booking: booking)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end
  end
end
