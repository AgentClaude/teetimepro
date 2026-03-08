# frozen_string_literal: true

module Types
  class PublicBookingType < Types::BaseObject
    description "Limited booking info for public lookup (no sensitive data)"

    field :id, ID, null: false
    field :confirmation_code, String, null: false
    field :status, String, null: false
    field :players_count, Integer, null: false
    field :total_cents, Integer, null: false
    field :booking_type, String, null: false
    field :cancelled_at, GraphQL::Types::ISO8601DateTime, null: true
    field :cancellation_reason, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :course_name, String, null: false
    field :tee_time_starts_at, GraphQL::Types::ISO8601DateTime, null: false
    field :tee_time_formatted, String, null: false
    field :tee_time_date, GraphQL::Types::ISO8601Date, null: false

    field :player_names, [String], null: false

    def course_name
      object.tee_time.tee_sheet.course.name
    end

    def tee_time_starts_at
      object.tee_time.starts_at
    end

    def tee_time_formatted
      object.tee_time.formatted_time
    end

    def tee_time_date
      object.tee_time.tee_sheet.date
    end

    def player_names
      object.booking_players.map(&:name)
    end
  end
end
