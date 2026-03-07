module Types
  class WeeklyRevenueType < Types::BaseObject
    description "Daily revenue data for weekly chart"

    field :date, GraphQL::Types::ISO8601Date, null: false,
          description: "Date of the revenue data"
    
    field :revenue_cents, Integer, null: false,
          description: "Revenue in cents for this date"
  end
end