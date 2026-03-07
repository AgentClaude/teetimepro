module Types
  class UpcomingBookingType < Types::BaseObject
    description "Simplified booking data for upcoming bookings list"

    field :id, ID, null: false,
          description: "Booking ID"
    
    field :confirmation_code, String, null: false,
          description: "Booking confirmation code"
    
    field :user_name, String, null: false,
          description: "Full name of the user who made the booking"
    
    field :course_name, String, null: false,
          description: "Name of the course"
    
    field :tee_time, GraphQL::Types::ISO8601DateTime, null: false,
          description: "Tee time start datetime"
    
    field :players_count, Integer, null: false,
          description: "Number of players in the booking"
    
    field :total_cents, Integer, null: false,
          description: "Total cost in cents"
  end
end
