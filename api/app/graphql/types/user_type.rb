module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :email, String, null: false
    field :first_name, String, null: false
    field :last_name, String, null: false
    field :full_name, String, null: false
    field :phone, String, null: true
    field :role, String, null: false
    field :organization_id, ID, null: false
    field :bookings_count, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :bookings, [Types::BookingType], null: false
    field :upcoming_bookings, [Types::BookingType], null: false
    field :past_bookings, [Types::BookingType], null: false
    field :golfer_profile, Types::GolferProfileType, null: true
    field :calendar_connections, [Types::CalendarConnectionType], null: false
    field :membership, Types::MembershipType, null: true
    field :loyalty_account, Types::LoyaltyAccountType, null: true
    field :audit_log, [Types::AuditLogType], null: false

    def audit_log
      object.versions.order(created_at: :desc)
    end

    def upcoming_bookings
      object.bookings.upcoming.includes(tee_time: { tee_sheet: :course })
    end

    def past_bookings
      object.bookings
        .joins(:tee_time)
        .where("tee_times.starts_at <= ?", Time.current)
        .includes(tee_time: { tee_sheet: :course })
        .order("tee_times.starts_at DESC")
        .limit(50)
    end

    def bookings_count
      object.bookings.count
    end

    def membership
      object.organization.memberships.where(user: object).active.first
    end

    def loyalty_account
      object.loyalty_account
    end
  end
end
