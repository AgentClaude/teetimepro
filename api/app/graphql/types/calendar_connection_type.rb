module Types
  class CalendarConnectionType < Types::BaseObject
    field :id, ID, null: false
    field :provider, String, null: false
    field :enabled, Boolean, null: false
    field :calendar_id, String, null: true
    field :calendar_name, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Don't expose sensitive token information
    def provider
      object.provider.titlecase
    end

    def calendar_name
      object.calendar_name || "#{object.provider.titlecase} Calendar"
    end
  end
end