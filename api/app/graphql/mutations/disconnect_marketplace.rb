module Mutations
  class DisconnectMarketplace < BaseMutation
    argument :connection_id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(connection_id:)
      org = require_auth!
      require_role!(:manager)

      result = Marketplace::DisconnectService.call(
        organization: org,
        connection_id: connection_id
      )

      if result.success?
        { success: true, errors: [] }
      else
        { success: false, errors: result.errors }
      end
    end
  end
end
