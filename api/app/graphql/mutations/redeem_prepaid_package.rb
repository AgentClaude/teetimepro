# frozen_string_literal: true

module Mutations
  class RedeemPrepaidPackage < BaseMutation
    argument :prepaid_purchase_id, ID, required: true
    argument :booking_id, ID, required: true
    argument :value_cents, Integer, required: false, description: "Amount to redeem for value cards"

    field :prepaid_purchase, Types::PrepaidPurchaseType, null: true
    field :errors, [String], null: false

    def resolve(prepaid_purchase_id:, booking_id:, value_cents: nil)
      org = require_auth!

      purchase = PrepaidPurchase.where(organization_id: org.id).find(prepaid_purchase_id)
      booking = Booking.joins(tee_time: { tee_sheet: :course })
                       .where(courses: { organization_id: org.id })
                       .find(booking_id)

      result = Prepaid::RedeemPackageService.call(
        prepaid_purchase: purchase,
        booking: booking,
        user: purchase.user,
        value_cents: value_cents
      )

      if result.success?
        { prepaid_purchase: result.data.purchase, errors: [] }
      else
        { prepaid_purchase: nil, errors: result.errors }
      end
    end
  end
end
