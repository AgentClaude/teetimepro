module Payments
  class RefundPaymentService < ApplicationService
    attr_accessor :payment, :amount_cents, :reason

    validates :payment, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Payment is not eligible for refund"]) unless payment.refundable?

      refund_amount = amount_cents || payment.remaining_refundable_amount
      return failure(["Refund amount exceeds remaining balance"]) if refund_amount > payment.remaining_refundable_amount
      return failure(["Refund amount must be positive"]) if refund_amount <= 0

      if payment.provider_stripe?
        process_stripe_refund(refund_amount)
      else
        process_manual_refund(refund_amount)
      end
    end

    private

    def process_stripe_refund(refund_amount)
      stripe_id = payment.stripe_payment_intent_id || payment.provider_transaction_id
      return failure(["No Stripe payment intent ID available"]) unless stripe_id

      refund = Stripe::Refund.create(
        payment_intent: stripe_id,
        amount: refund_amount,
        reason: "requested_by_customer",
        metadata: {
          booking_id: payment.booking_id,
          reason: reason || "Refund"
        }
      )

      apply_refund(refund_amount)
      success(payment: payment, stripe_refund: refund)
    rescue Stripe::StripeError => e
      failure(["Refund failed: #{e.message}"])
    end

    def process_manual_refund(refund_amount)
      apply_refund(refund_amount)
      success(payment: payment)
    end

    def apply_refund(refund_amount)
      new_refund_total = payment.refund_amount_cents.to_i + refund_amount
      full_refund = new_refund_total >= payment.amount_cents

      payment.update!(
        refund_amount_cents: new_refund_total,
        refund_amount_currency: payment.amount_currency,
        status: full_refund ? :refunded : :partially_refunded,
        refund_reason: reason,
        refunded_at: Time.current
      )
    end
  end
end
