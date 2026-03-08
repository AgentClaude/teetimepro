# frozen_string_literal: true

module Mutations
  class CollectDeposit < BaseMutation
    argument :booking_id, ID, required: true
    argument :amount_cents, Integer, required: true
    argument :payment_method, Types::PaymentMethodEnum, required: false
    argument :provider_transaction_id, String, required: false

    field :booking, Types::BookingType, null: true
    field :payment, Types::PaymentType, null: true
    field :errors, [String], null: false

    def resolve(booking_id:, amount_cents:, payment_method: nil, provider_transaction_id: nil)
      org = require_auth!

      booking = Booking.joins(tee_time: { tee_sheet: :course })
                       .where(courses: { organization_id: org.id })
                       .find(booking_id)

      result = Deposits::CollectDepositService.call(
        booking: booking,
        amount_cents: amount_cents,
        payment_method: payment_method,
        provider_transaction_id: provider_transaction_id
      )

      if result.success?
        { booking: result.data.booking, payment: result.data.payment, errors: [] }
      else
        { booking: nil, payment: nil, errors: result.errors }
      end
    end
  end
end
