module Types
  class DateRangeType < Types::BaseObject
    field :start_date, GraphQL::Types::ISO8601Date, null: false
    field :end_date, GraphQL::Types::ISO8601Date, null: false
    field :days, Integer, null: false
  end
end
