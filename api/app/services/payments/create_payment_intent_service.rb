module Payments
  class CreatePaymentIntentService < ApplicationService
    attr_accessor :tee_time, :players_count, :user, :organization

    validates :tee_time, :players_count, :user, :organization, presence: true

    def call
      return validation_failure(self) unless valid?

      amount_cents = tee_time.price_cents * players_count

      intent_params = {
        amount: amount_cents,
        currency: 'usd',
        automatic_payment_methods: { enabled: true },
        metadata: {
          tee_time_id: tee_time.id,
          user_id: user.id,
          organization_id: organization.id
        }
      }

      if organization.respond_to?(:stripe_account_id) && organization.stripe_account_id.present?
        intent_params[:transfer_data] = { destination: organization.stripe_account_id }
      end

      intent = Stripe::PaymentIntent.create(intent_params)

      success(client_secret: intent.client_secret, payment_intent_id: intent.id)
    rescue Stripe::StripeError => e
      failure(["Payment setup failed: #{e.message}"])
    end
  end
end