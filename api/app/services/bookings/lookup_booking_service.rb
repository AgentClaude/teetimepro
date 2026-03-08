# frozen_string_literal: true

module Bookings
  class LookupBookingService < ApplicationService
    attr_accessor :confirmation_code, :email

    validates :confirmation_code, presence: true
    validates :email, presence: true

    def call
      return validation_failure(self) unless valid?

      booking = Booking
        .joins(:user)
        .where(confirmation_code: confirmation_code.strip.upcase)
        .where(users: { email: email.strip.downcase })
        .includes(tee_time: { tee_sheet: :course }, user: [], booking_players: [])
        .first

      return failure(["Booking not found. Please check your confirmation code and email."]) unless booking

      success(booking: booking)
    end
  end
end
