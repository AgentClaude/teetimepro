# frozen_string_literal: true

module Mutations
  class CreatePrepaidPackage < BaseMutation
    argument :name, String, required: true
    argument :description, String, required: false
    argument :package_type, Types::PackageTypeEnum, required: true
    argument :rounds_included, Integer, required: false
    argument :price_cents, Integer, required: true
    argument :value_cents, Integer, required: false
    argument :validity_days, Integer, required: false
    argument :max_players_per_round, Integer, required: false
    argument :transferable, Boolean, required: false
    argument :course_id, ID, required: false
    argument :restrictions, GraphQL::Types::JSON, required: false
    argument :available_from, GraphQL::Types::ISO8601DateTime, required: false
    argument :available_until, GraphQL::Types::ISO8601DateTime, required: false

    field :prepaid_package, Types::PrepaidPackageType, null: true
    field :errors, [String], null: false

    def resolve(**args)
      org = require_auth!

      result = Prepaid::CreatePackageService.call(
        organization: org,
        **args
      )

      if result.success?
        { prepaid_package: result.data.package, errors: [] }
      else
        { prepaid_package: nil, errors: result.errors }
      end
    end
  end
end
