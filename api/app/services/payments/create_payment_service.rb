module Payments
  class CreatePaymentService < ApplicationService
    attr_accessor :booking, :organization, :user, :amount_cents, :currency,
                  :payment_method, :provider, :provider_transaction_id, :metadata

    validates :booking, :organization, :user, :amount_cents, presence: true

    def call
      return validation_failure(self) unless valid?

      payment = Payment.create!(
        booking: booking,
        organization: organization,
        user: user,
        amount_cents: amount_cents,
        amount_currency: currency || "USD",
        status: :pending,
        payment_method: payment_method || :card,
        provider: provider || :stripe,
        provider_transaction_id: provider_transaction_id,
        metadata: metadata || {}
      )

      success(payment: payment)
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end
  end
end
