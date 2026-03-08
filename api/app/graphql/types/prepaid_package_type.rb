# frozen_string_literal: true

module Types
  class PrepaidPackageType < Types::BaseObject
    field :id, ID, null: false
    field :organization, Types::OrganizationType, null: false
    field :course, Types::CourseType, null: true
    field :name, String, null: false
    field :description, String, null: true
    field :package_type, Types::PackageTypeEnum, null: false
    field :rounds_included, Integer, null: true
    field :price, Types::MoneyType, null: false
    field :value, Types::MoneyType, null: true
    field :validity_days, Integer, null: true
    field :max_players_per_round, Integer, null: false
    field :transferable, Boolean, null: false
    field :active, Boolean, null: false
    field :restrictions, GraphQL::Types::JSON, null: false
    field :available_from, GraphQL::Types::ISO8601DateTime, null: true
    field :available_until, GraphQL::Types::ISO8601DateTime, null: true
    field :available, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    def price
      object.price
    end

    def value
      return nil unless object.value_cents.present?

      object.value
    end

    def available
      object.available?
    end
  end
end
