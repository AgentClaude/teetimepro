module Mutations
  class RefundPayment < BaseMutation
    argument :payment_id, ID, required: true
    argument :amount_cents, Integer, required: false, description: "Partial refund amount. Omit for full refund."
    argument :reason, String, required: false

    field :payment, Types::PaymentType, null: true
    field :errors, [String], null: false

    def resolve(payment_id:, amount_cents: nil, reason: nil)
      org = require_auth!
      payment = Payment.joins(booking: { tee_time: { tee_sheet: :course } })
                       .where(courses: { organization_id: org.id })
                       .find(payment_id)

      result = Payments::RefundPaymentService.call(
        payment: payment,
        amount_cents: amount_cents,
        reason: reason
      )

      if result.success?
        { payment: result.data.payment, errors: [] }
      else
        { payment: nil, errors: result.errors }
      end
    end
  end
end
