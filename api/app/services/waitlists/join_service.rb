# frozen_string_literal: true

module Waitlists
  class JoinService < ApplicationService
    attr_accessor :user, :tee_time, :players_requested, :organization

    validates :user, :tee_time, :organization, presence: true
    validates :players_requested, presence: true, numericality: { in: 1..5 }

    def call
      return validation_failure(self) unless valid?
      return failure(["Tee time must be in the future"]) if tee_time.starts_at <= Time.current
      return failure(["You are already on the waitlist for this tee time"]) if already_waitlisted?

      entry = WaitlistEntry.new(
        user: user,
        tee_time: tee_time,
        organization: organization,
        players_requested: players_requested || 1,
        status: :waiting
      )

      if entry.save
        Rails.logger.info("User #{user.id} joined waitlist for tee time #{tee_time.id}")
        success(waitlist_entry: entry)
      else
        failure(entry.errors.full_messages)
      end
    end

    private

    def already_waitlisted?
      WaitlistEntry.exists?(user: user, tee_time: tee_time, status: :waiting)
    end
  end
end
