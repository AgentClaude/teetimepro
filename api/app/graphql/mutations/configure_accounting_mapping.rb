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

      # Validate category
      valid_categories = %w[green_fees cart_fees merchandise food_beverage lessons tournaments bank_deposits]
      unless valid_categories.include?(category)
        return { integration: nil, errors: ["Invalid category. Must be one of: #{valid_categories.join(', ')}"] }
      end

      # Find the integration
      integration = org.accounting_integrations.find_by(provider: provider)
      unless integration
        return { integration: nil, errors: ["#{provider.titleize} integration not found"] }
      end

      # Update the mapping
      integration.set_account_mapping(category, account_id, account_name)

      { integration: integration, errors: [] }
    rescue => e
      { integration: nil, errors: ["Failed to update mapping: #{e.message}"] }
    end
  end
end