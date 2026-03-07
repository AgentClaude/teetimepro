module Payments
  class CapturePaymentService < ApplicationService
    attr_accessor :payment, :provider_transaction_id

    validates :payment, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Payment is not in a capturable state"]) unless payment.capturable?

      payment.update!(
        status: :captured,
        paid_at: Time.current,
        provider_transaction_id: provider_transaction_id || payment.provider_transaction_id
      )

      success(payment: payment)
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end
  end
end
