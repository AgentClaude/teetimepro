module Mutations
  class ConnectMarketplace < BaseMutation
    argument :course_id, ID, required: true
    argument :provider, Types::MarketplaceProviderEnum, required: true
    argument :api_key, String, required: true
    argument :api_secret, String, required: false
    argument :external_course_id, String, required: false
    argument :settings, GraphQL::Types::JSON, required: false

    field :marketplace_connection, Types::MarketplaceConnectionType, null: true
    field :errors, [String], null: false

    def resolve(course_id:, provider:, api_key:, api_secret: nil, external_course_id: nil, settings: nil)
      org = require_auth!
      require_role!(:manager)

      course = org.courses.find_by(id: course_id)
      return { marketplace_connection: nil, errors: ["Course not found"] } unless course

      credentials = { "api_key" => api_key }
      credentials["api_secret"] = api_secret if api_secret.present?
      credentials["course_id"] = external_course_id if external_course_id.present?

      result = Marketplace::ConnectService.call(
        organization: org,
        course: course,
        provider: provider,
        credentials: credentials,
        settings: settings || {}
      )

      if result.success?
        { marketplace_connection: result.data[:connection], errors: [] }
      else
        { marketplace_connection: nil, errors: result.errors }
      end
    end
  end
end
