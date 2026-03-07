module Mutations
  class CreatePayment < BaseMutation
    argument :booking_id, ID, required: true
    argument :amount_cents, Integer, required: true
    argument :currency, String, required: false
    argument :payment_method, Types::PaymentMethodEnum, required: false
    argument :provider, Types::PaymentProviderEnum, required: false
    argument :provider_transaction_id, String, required: false
    argument :metadata, GraphQL::Types::JSON, required: false

    field :payment, Types::PaymentType, null: true
    field :errors, [String], null: false

    def resolve(booking_id:, amount_cents:, currency: nil, payment_method: nil,
                provider: nil, provider_transaction_id: nil, metadata: nil)
      org = require_auth!
      booking = Booking.joins(tee_time: { tee_sheet: :course })
                       .where(courses: { organization_id: org.id })
                       .find(booking_id)

      result = Payments::CreatePaymentService.call(
        booking: booking,
        organization: org,
        user: current_user,
        amount_cents: amount_cents,
        currency: currency,
        payment_method: payment_method,
        provider: provider,
        provider_transaction_id: provider_transaction_id,
        metadata: metadata
      )

      if result.success?
        { payment: result.data.payment, errors: [] }
      else
        { payment: nil, errors: result.errors }
      end
    end
  end
end
