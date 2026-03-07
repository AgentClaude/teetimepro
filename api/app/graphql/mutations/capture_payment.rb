module Mutations
  class CapturePayment < BaseMutation
    argument :payment_id, ID, required: true
    argument :provider_transaction_id, String, required: false

    field :payment, Types::PaymentType, null: true
    field :errors, [String], null: false

    def resolve(payment_id:, provider_transaction_id: nil)
      org = require_auth!
      payment = Payment.joins(booking: { tee_time: { tee_sheet: :course } })
                       .where(courses: { organization_id: org.id })
                       .find(payment_id)

      result = Payments::CapturePaymentService.call(
        payment: payment,
        provider_transaction_id: provider_transaction_id
      )

      if result.success?
        { payment: result.data.payment, errors: [] }
      else
        { payment: nil, errors: result.errors }
      end
    end
  end
end
