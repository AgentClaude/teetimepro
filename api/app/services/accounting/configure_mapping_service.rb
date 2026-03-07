module Accounting
  class ConfigureMappingService < ApplicationService
    attr_accessor :organization, :provider, :category, :account_id, :account_name

    VALID_CATEGORIES = %w[green_fees cart_fees merchandise food_beverage lessons tournaments bank_deposits].freeze

    validates :organization, presence: true
    validates :provider, presence: true, inclusion: { in: %w[quickbooks xero] }
    validates :category, presence: true, inclusion: { in: VALID_CATEGORIES }
    validates :account_id, presence: true
    validates :account_name, presence: true

    def call
      return failure(errors: errors.full_messages) if errors.any?

      begin
        integration = organization.accounting_integrations.find_by(provider: provider)
        unless integration
          return failure(errors: ["#{provider.titleize} integration not found"])
        end

        integration.set_account_mapping(category, account_id, account_name)

        success(integration: integration)
      rescue => e
        failure(errors: ["Failed to update mapping: #{e.message}"])
      end
    end
  end
end
