module Mutations
  class UpdateMarketplaceSettings < BaseMutation
    argument :connection_id, ID, required: true
    argument :settings, GraphQL::Types::JSON, required: false
    argument :status, String, required: false

    field :marketplace_connection, Types::MarketplaceConnectionType, null: true
    field :errors, [String], null: false

    def resolve(connection_id:, settings: nil, status: nil)
      org = require_auth!
      require_role!(:manager)

      result = Marketplace::UpdateSettingsService.call(
        organization: org,
        connection_id: connection_id,
        settings: settings,
        status: status
      )

      if result.success?
        { marketplace_connection: result.data[:connection], errors: [] }
      else
        { marketplace_connection: nil, errors: result.errors }
      end
    end
  end
end
