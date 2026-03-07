# frozen_string_literal: true

module Waitlists
  class LeaveService < ApplicationService
    attr_accessor :user, :tee_time

    validates :user, :tee_time, presence: true

    def call
      return validation_failure(self) unless valid?

      entry = WaitlistEntry.find_by(user: user, tee_time: tee_time, status: :waiting)
      return failure(["You are not on the waitlist for this tee time"]) unless entry

      entry.update!(status: :cancelled)
      Rails.logger.info("User #{user.id} left waitlist for tee time #{tee_time.id}")

      success(waitlist_entry: entry)
    end
  end
end
