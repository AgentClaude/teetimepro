module Types
  class BookingType < Types::BaseObject
    field :id, ID, null: false
    field :confirmation_code, String, null: false
    field :status, String, null: false
    field :players_count, Integer, null: false
    field :total_cents, Integer, null: false
    field :notes, String, null: true
    field :cancellable, Boolean, null: false
    field :cancelled_at, GraphQL::Types::ISO8601DateTime, null: true
    field :cancellation_reason, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :tee_time, Types::TeeTimeType, null: false
    field :user, Types::UserType, null: false
    field :booking_players, [Types::BookingPlayerType], null: false
    field :fnb_tabs, [Types::FnbTabType], null: false, description: "F&B tabs linked to this booking"
    field :turn_order, Types::FnbTabType, null: true, description: "Active turn order for this booking"
    field :has_turn_order, Boolean, null: false
    field :audit_log, [Types::AuditLogType], null: false

    def cancellable
      object.cancellable?
    end

    def turn_order
      object.fnb_tabs.turn_orders.open_tabs.first
    end

    def has_turn_order
      object.fnb_tabs.turn_orders.open_tabs.exists?
    end

    def audit_log
      object.versions.order(created_at: :desc)
    end
  end
end
