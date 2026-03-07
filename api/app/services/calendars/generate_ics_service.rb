module Calendars
  class GenerateIcsService < ApplicationService
    require 'icalendar'

    attr_accessor :booking

    validates :booking, presence: true

    def call
      return validation_failure(self) unless valid?

      begin
        calendar = Icalendar::Calendar.new

        event = Icalendar::Event.new
        event.dtstart = Icalendar::Values::DateTime.new(booking.starts_at)
        event.dtend = Icalendar::Values::DateTime.new(booking.starts_at + 2.hours) # Assume 2-hour round
        event.summary = "Golf at #{booking.course.name}"
        event.description = build_event_description
        event.location = build_event_location
        event.uid = "booking-#{booking.id}@teetimespro.com"
        event.organizer = "TeeTimes Pro <noreply@teetimespro.com>"
        event.url = build_booking_url

        # Add alarm/reminder 1 hour before
        alarm = Icalendar::Alarm.new
        alarm.action = "DISPLAY"
        alarm.description = "Golf tee time reminder"
        alarm.trigger = "-PT1H" # 1 hour before
        event.add_alarm(alarm)

        calendar.add_event(event)
        calendar.publish

        success(
          ics_content: calendar.to_ical,
          filename: build_filename
        )
      rescue => e
        failure(["Error generating ICS file: #{e.message}"])
      end
    end

    private

    def build_event_description
      description = []
      description << "Golf booking at #{booking.course.name}"
      description << ""
      description << "Confirmation Code: #{booking.confirmation_code}"
      description << "Players: #{booking.players_count}"
      description << "Tee Time: #{booking.starts_at.strftime('%B %d, %Y at %I:%M %p')}"
      description << ""
      
      if booking.notes.present?
        description << "Notes: #{booking.notes}"
        description << ""
      end

      # Add player names if available
      if booking.booking_players.any?
        description << "Players:"
        booking.booking_players.each_with_index do |player, index|
          description << "  #{index + 1}. #{player.name}"
        end
        description << ""
      end

      description << "Powered by TeeTimes Pro"
      description.join("\n")
    end

    def build_event_location
      course = booking.course
      location_parts = [course.name]
      
      if course.address.present?
        location_parts << course.address
      end
      
      if course.city.present? && course.state.present?
        location_parts << "#{course.city}, #{course.state}"
      end

      if course.zip_code.present?
        location_parts << course.zip_code
      end

      location_parts.join(", ")
    end

    def build_filename
      date = booking.starts_at.strftime('%Y%m%d')
      course_name = booking.course.name.parameterize
      "golf-booking-#{course_name}-#{date}.ics"
    end

    def build_booking_url
      # This would be the URL to view the booking in your app
      # For now, return the organization's domain or a generic URL
      "https://app.teetimespro.com/bookings/#{booking.confirmation_code}"
    end
  end
end