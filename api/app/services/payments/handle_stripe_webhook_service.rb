module Payments
  class HandleStripeWebhookService < ApplicationService
    attr_accessor :stripe_event_id, :event_type, :event_data

    validates :stripe_event_id, :event_type, :event_data, presence: true

    def call
      return validation_failure(self) unless valid?

      # Check if we've already processed this event (idempotency)
      return success(message: "Event already processed") if StripeEvent.already_processed?(stripe_event_id)

      # Create or find the event record
      stripe_event = create_or_find_stripe_event

      begin
        case event_type
        when "payment_intent.succeeded"
          handle_payment_succeeded(stripe_event)
        when "payment_intent.payment_failed"
          handle_payment_failed(stripe_event)
        when "charge.refunded"
          handle_charge_refunded(stripe_event)
        when "charge.dispute.created"
          handle_charge_dispute_created(stripe_event)
        else
          Rails.logger.info("Unhandled Stripe webhook event type: #{event_type}")
          stripe_event.mark_processed! # Mark as processed even if we don't handle it
          return success(message: "Event type not handled but marked as processed")
        end

        stripe_event.mark_processed!
        success(stripe_event: stripe_event)

      rescue StandardError => e
        Rails.logger.error("Failed to process Stripe webhook: #{e.message}")
        stripe_event.mark_failed!(e.message)
        failure(["Failed to process webhook: #{e.message}"])
      end
    end

    private

    def create_or_find_stripe_event
      StripeEvent.find_or_create_by(stripe_event_id: stripe_event_id) do |event|
        event.event_type = event_type
        event.payload = event_data
        event.status = :pending
      end
    end

    def handle_payment_succeeded(stripe_event)
      payment_intent_id = event_data.dig("id")
      return unless payment_intent_id

      payment = Payment.find_by(stripe_payment_intent_id: payment_intent_id)
      return unless payment

      payment.update!(status: :completed)
      
      # Note: Booking is already confirmed when created, no status update needed

      Rails.logger.info("Payment #{payment.id} marked as completed for PI #{payment_intent_id}")
    end

    def handle_payment_failed(stripe_event)
      payment_intent_id = event_data.dig("id")
      return unless payment_intent_id

      payment = Payment.find_by(stripe_payment_intent_id: payment_intent_id)
      return unless payment

      payment.update!(status: :failed)

      Rails.logger.info("Payment #{payment.id} marked as failed for PI #{payment_intent_id}")
    end

    def handle_charge_refunded(stripe_event)
      charge_data = event_data.dig("data", "object")
      payment_intent_id = charge_data&.dig("payment_intent")
      return unless payment_intent_id

      payment = Payment.find_by(stripe_payment_intent_id: payment_intent_id)
      return unless payment

      refund_amount_cents = charge_data.dig("amount_refunded") || 0
      total_amount_cents = charge_data.dig("amount") || 0

      # Determine refund status
      if refund_amount_cents >= total_amount_cents
        payment.update!(
          status: :refunded,
          refund_amount_cents: refund_amount_cents
        )
      else
        payment.update!(
          status: :partially_refunded,
          refund_amount_cents: refund_amount_cents
        )
      end

      Rails.logger.info("Payment #{payment.id} refund processed: #{refund_amount_cents} cents")
    end

    def handle_charge_dispute_created(stripe_event)
      charge_id = event_data.dig("data", "object", "charge")
      dispute_amount = event_data.dig("data", "object", "amount")
      
      # For now, just log the dispute. In a real system, you might:
      # - Flag the payment as disputed
      # - Send notifications to admins
      # - Create a dispute record
      Rails.logger.warn("Dispute created for charge #{charge_id}, amount: #{dispute_amount}")
      
      # You could extend this to find the payment and flag it
      # payment = Payment.joins(:stripe_charges).find_by(stripe_charges: { charge_id: charge_id })
      # payment&.update!(disputed: true)
    end
  end
end