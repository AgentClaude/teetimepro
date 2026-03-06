module Payments
  class RefundPaymentService < ApplicationService
    attr_accessor :payment, :amount_cents, :reason

    validates :payment, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Payment is not eligible for refund"]) unless payment.completed?

      refund_amount = amount_cents || payment.remaining_refundable_amount
      return failure(["Refund amount exceeds remaining balance"]) if refund_amount > payment.remaining_refundable_amount

      begin
        refund = Stripe::Refund.create(
          payment_intent: payment.stripe_payment_intent_id,
          amount: refund_amount,
          reason: "requested_by_customer",
          metadata: {
            booking_id: payment.booking_id,
            reason: reason || "Cancellation refund"
          }
        )

        new_refund_total = payment.refund_amount_cents.to_i + refund_amount
        new_status = new_refund_total >= payment.amount_cents ? :refunded : :partially_refunded

        payment.update!(
          refund_amount_cents: new_refund_total,
          refund_amount_currency: "USD",
          status: new_status
        )

        success(payment: payment, stripe_refund: refund)
      rescue Stripe::StripeError => e
        failure(["Refund failed: #{e.message}"])
      end
    end
  end
end
