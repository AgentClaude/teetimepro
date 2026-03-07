module Mutations
  class ConfigureAccountingMapping < BaseMutation
    argument :provider, Types::AccountingProviderEnum, required: true
    argument :category, String, required: true
    argument :account_id, String, required: true
    argument :account_name, String, required: true

    field :integration, Types::AccountingIntegrationType, null: true
    field :errors, [String], null: false

    def resolve(provider:, category:, account_id:, account_name:)
      org = require_auth!
      require_role!(:manager)

      result = Accounting::ConfigureMappingService.call(
        organization: org,
        provider: provider,
        category: category,
        account_id: account_id,
        account_name: account_name
      )

      if result.success?
        { integration: result.integration, errors: [] }
      else
        { integration: nil, errors: result.errors }
      end
    end
  end
end
