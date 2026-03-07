module Mutations
  class ConnectAccountingIntegration < BaseMutation
    argument :provider, Types::AccountingProviderEnum, required: true
    argument :oauth_code, String, required: true
    argument :oauth_state, String, required: true
    argument :realm_id, String, required: false # QuickBooks only
    argument :tenant_id, String, required: false # Xero only

    field :integration, Types::AccountingIntegrationType, null: true
    field :errors, [String], null: false

    def resolve(provider:, oauth_code:, oauth_state:, realm_id: nil, tenant_id: nil)
      org = require_auth!
      require_role!(:manager)

      oauth_params = {
        code: oauth_code,
        state: oauth_state,
        realmId: realm_id,
        tenantId: tenant_id
      }.compact

      result = Accounting::ConnectService.call(
        organization: org,
        provider: provider,
        oauth_params: oauth_params
      )

      if result.success?
        { integration: result.integration, errors: [] }
      else
        { integration: nil, errors: result.errors }
      end
    end
  end
end