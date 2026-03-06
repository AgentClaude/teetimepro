module Payments
  class ProcessPaymentService < ApplicationService
    attr_accessor :booking, :payment_method_id, :stripe_account_id

    validates :booking, :payment_method_id, presence: true

    def call
      return validation_failure(self) unless valid?

      payment = Payment.create!(
        booking: booking,
        amount_cents: booking.total_cents,
        amount_currency: "USD",
        status: :pending,
        stripe_payment_intent_id: "pending_#{SecureRandom.hex(8)}"
      )

      begin
        intent_params = {
          amount: booking.total_cents,
          currency: "usd",
          payment_method: payment_method_id,
          confirm: true,
          metadata: {
            booking_id: booking.id,
            confirmation_code: booking.confirmation_code
          }
        }

        # Use Stripe Connect if org has a connected account
        if stripe_account_id.present?
          intent_params[:transfer_data] = { destination: stripe_account_id }
        end

        intent = Stripe::PaymentIntent.create(intent_params)

        payment.update!(
          stripe_payment_intent_id: intent.id,
          status: intent.status == "succeeded" ? :completed : :pending
        )

        success(payment: payment, stripe_intent: intent)
      rescue Stripe::CardError => e
        payment.update!(status: :failed)
        failure(["Payment failed: #{e.message}"])
      rescue Stripe::StripeError => e
        payment.update!(status: :failed)
        failure(["Payment processing error: #{e.message}"])
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end
  end
end
