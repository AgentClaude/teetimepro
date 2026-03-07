module Types
  class CourseType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :slug, String, null: false
    field :holes, Integer, null: false
    field :interval_minutes, Integer, null: false
    field :max_players_per_slot, Integer, null: false
    field :first_tee_time, String, null: false
    field :last_tee_time, String, null: false
    field :weekday_rate_cents, Integer, null: true
    field :weekend_rate_cents, Integer, null: true
    field :twilight_rate_cents, Integer, null: true
    field :address, String, null: true
    field :phone, String, null: true
    field :organization_id, ID, null: false
    field :voice_config, GraphQL::Types::JSON, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :tee_sheets, [Types::TeeSheetType], null: false

    def tee_sheets
      object.tee_sheets.upcoming.order(:date).limit(30)
    end

    def first_tee_time
      object.first_tee_time&.strftime("%H:%M")
    end

    def last_tee_time
      object.last_tee_time&.strftime("%H:%M")
    end
  end
end
