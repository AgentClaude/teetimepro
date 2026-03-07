module Types
  class DashboardStatsType < Types::BaseObject
    description "Dashboard statistics for the organization"

    field :todays_bookings, Integer, null: false,
          description: "Number of confirmed/checked-in/completed bookings for today"
    
    field :todays_revenue_cents, Integer, null: false,
          description: "Total revenue in cents for today's bookings"
    
    field :active_members, Integer, null: false,
          description: "Number of active members (users with bookings)"
    
    field :utilization_percentage, Float, null: false,
          description: "Average utilization percentage across tee sheets for the date"
    
    field :upcoming_bookings, [Types::UpcomingBookingType], null: false,
          description: "Next 5 upcoming bookings"
    
    field :weekly_revenue, [Types::WeeklyRevenueType], null: false,
          description: "Revenue data for the last 7 days"
  end
end