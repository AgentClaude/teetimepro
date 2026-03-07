module Types
  class AccountingIntegrationType < Types::BaseObject
    field :id, ID, null: false
    field :organization, Types::OrganizationType, null: false
    field :provider, Types::AccountingProviderEnum, null: false
    field :status, Types::AccountingIntegrationStatusEnum, null: false
    field :company_name, String, null: true
    field :country_code, String, null: true
    field :connected_at, GraphQL::Types::ISO8601DateTime, null: true
    field :last_sync_at, GraphQL::Types::ISO8601DateTime, null: true
    field :account_mapping, GraphQL::Types::JSON, null: false
    field :settings, GraphQL::Types::JSON, null: false
    field :last_error_message, String, null: true
    field :last_error_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Helper fields
    field :connected, Boolean, null: false
    field :company_id, String, null: true

    def connected
      object.connected?
    end

    def company_id
      object.company_id
    end
  end
end
