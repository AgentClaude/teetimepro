module Mutations
  class SyncMarketplace < BaseMutation
    argument :connection_id, ID, required: true

    field :created_count, Integer, null: false
    field :expired_count, Integer, null: false
    field :errors, [String], null: false

    def resolve(connection_id:)
      org = require_auth!
      require_role!(:manager)

      connection = MarketplaceConnection.for_organization(org)
                                        .find_by(id: connection_id)

      return { created_count: 0, expired_count: 0, errors: ["Connection not found"] } unless connection

      result = Marketplace::SyndicateTeeTimesService.call(connection: connection)

      if result.success?
        {
          created_count: result.data[:created_count],
          expired_count: result.data[:expired_count],
          errors: result.data[:errors] || []
        }
      else
        { created_count: 0, expired_count: 0, errors: result.errors }
      end
    end
  end
end
