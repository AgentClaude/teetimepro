# frozen_string_literal: true

module Waitlists
  class NotifyService < ApplicationService
    attr_accessor :tee_time

    validates :tee_time, presence: true

    def call
      return validation_failure(self) unless valid?
      return success(notified_count: 0) if tee_time.starts_at <= Time.current

      entries = tee_time.waitlist_entries.active.by_position
      return success(notified_count: 0) if entries.empty?

      available = tee_time.available_spots
      return success(notified_count: 0) if available <= 0

      notified = []

      entries.each do |entry|
        # Notify users whose requested player count fits the available spots
        if entry.players_requested <= available
          send_notification(entry)
          entry.notify!
          notified << entry
        end
      end

      Rails.logger.info(
        "Notified #{notified.size} waitlisted users for tee time #{tee_time.id} " \
        "(#{available} spots available)"
      )

      success(notified_count: notified.size, entries: notified)
    end

    private

    def send_notification(entry)
      WaitlistMailer.slot_available(
        waitlist_entry: entry,
        organization: entry.organization
      ).deliver_later
    end
  end
end
