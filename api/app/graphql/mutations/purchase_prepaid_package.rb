# frozen_string_literal: true

module Mutations
  class PurchasePrepaidPackage < BaseMutation
    argument :prepaid_package_id, ID, required: true
    argument :user_id, ID, required: true

    field :prepaid_purchase, Types::PrepaidPurchaseType, null: true
    field :errors, [String], null: false

    def resolve(prepaid_package_id:, user_id:)
      org = require_auth!

      package = PrepaidPackage.where(organization_id: org.id).find(prepaid_package_id)
      user = User.where(organization_id: org.id).find(user_id)

      result = Prepaid::PurchasePackageService.call(
        prepaid_package: package,
        user: user,
        organization: org
      )

      if result.success?
        { prepaid_purchase: result.data.purchase, errors: [] }
      else
        { prepaid_purchase: nil, errors: result.errors }
      end
    end
  end
end
