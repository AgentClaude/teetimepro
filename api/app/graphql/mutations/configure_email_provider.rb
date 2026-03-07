# frozen_string_literal: true

module Mutations
  class ConfigureEmailProvider < BaseMutation
    argument :provider_type, String, required: true
    argument :api_key, String, required: true
    argument :from_email, String, required: true
    argument :from_name, String, required: false
    argument :is_default, Boolean, required: false
    argument :settings, GraphQL::Types::JSON, required: false

    field :provider, Types::EmailProviderType, null: true
    field :verified, Boolean, null: false
    field :errors, [String], null: false

    def resolve(**args)
      org = require_auth!
      require_role!(:manager)

      result = Campaigns::ConfigureEmailProviderService.call(
        organization: org,
        user: current_user,
        **args
      )

      if result.success?
        {
          provider: result.data[:provider],
          verified: result.data[:verified],
          errors: []
        }
      else
        { provider: nil, verified: false, errors: result.errors }
      end
    end
  end
end
