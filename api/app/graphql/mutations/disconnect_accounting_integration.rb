module Mutations
  class DisconnectAccountingIntegration < BaseMutation
    argument :provider, Types::AccountingProviderEnum, required: true

    field :success, Boolean, null: false
    field :message, String, null: true
    field :errors, [String], null: false

    def resolve(provider:)
      org = require_auth!
      require_role!(:manager)

      result = Accounting::DisconnectService.call(
        organization: org,
        provider: provider
      )

      if result.success?
        { success: true, message: result.message, errors: [] }
      else
        { success: false, message: nil, errors: result.errors }
      end
    end
  end
end
