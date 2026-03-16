# frozen_string_literal: true

module Bookings
  class LookupBookingService < ApplicationService
    attr_accessor :confirmation_code, :email, :organization

    validates :confirmation_code, presence: true
    validates :email, presence: true

    def call
      return validation_failure(self) unless valid?

      bookings_scope = Booking.joins(:user)
      
      # If organization is provided, scope to that organization
      bookings_scope = bookings_scope.for_organization(organization) if organization

      booking = bookings_scope
        .where(confirmation_code: confirmation_code.strip.upcase)
        .where("LOWER(users.email) = ?", email.strip.downcase)
        .includes(tee_time: { tee_sheet: :course }, user: [], booking_players: [])
        .first

      return failure(["Booking not found. Please check your confirmation code and email."]) unless booking

      success(booking: booking)
    end
  end
end
