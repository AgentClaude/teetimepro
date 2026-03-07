module Calendars
  class SyncBookingService < ApplicationService
    require 'google/apis/calendar_v3'

    attr_accessor :booking, :action

    validates :booking, presence: true
    validates :action, inclusion: { in: %w[create update delete] }

    def call
      return validation_failure(self) unless valid?

      # Get user's enabled calendar connections
      enabled_connections = booking.user.calendar_connections.enabled
      
      return success(message: "No calendar connections enabled") if enabled_connections.empty?

      results = []
      
      enabled_connections.each do |connection|
        result = sync_with_connection(connection)
        results << { provider: connection.provider, result: result }
      end

      if results.all? { |r| r[:result].success? }
        success(sync_results: results)
      else
        # Log failures but don't fail the overall operation
        failed_results = results.select { |r| r[:result].failure? }
        Rails.logger.warn "Calendar sync failures: #{failed_results.map { |r| r[:result].errors }.join(', ')}"
        
        success(
          sync_results: results,
          message: "Some calendar syncs failed but booking was processed successfully"
        )
      end
    end

    private

    def sync_with_connection(connection)
      case connection.provider
      when 'google'
        sync_with_google(connection)
      when 'apple'
        # Apple calendar sync would be implemented here
        # For now, just return success
        success(message: "Apple calendar sync not implemented")
      else
        failure(["Unknown provider: #{connection.provider}"])
      end
    end

    def sync_with_google(connection)
      return failure(["Google Calendar connection is disabled"]) unless connection.enabled?

      # Check if token needs refresh
      if connection.needs_refresh?
        refresh_result = Calendars::RefreshTokenService.call(connection: connection)
        return refresh_result unless refresh_result.success?
        connection.reload
      end

      begin
        service = Google::Apis::CalendarV3::CalendarService.new
        service.authorization = connection.access_token

        case action
        when 'create'
          create_google_event(service, connection)
        when 'update'
          update_google_event(service, connection)
        when 'delete'
          delete_google_event(service, connection)
        end
      rescue Google::Apis::Error => e
        Rails.logger.error "Google Calendar API error: #{e.message}"
        failure(["Google Calendar sync failed: #{e.message}"])
      rescue => e
        Rails.logger.error "Calendar sync error: #{e.message}"
        failure(["Calendar sync failed: #{e.message}"])
      end
    end

    def create_google_event(service, connection)
      event = build_google_event

      created_event = service.insert_event(connection.calendar_id, event)
      
      # Store the event ID for future updates/deletes
      booking.update!(calendar_event_id: created_event.id)

      success(
        event_id: created_event.id,
        message: "Event created in Google Calendar"
      )
    end

    def update_google_event(service, connection)
      return failure(["No calendar event ID stored for this booking"]) unless booking.calendar_event_id

      event = build_google_event
      
      updated_event = service.update_event(
        connection.calendar_id, 
        booking.calendar_event_id, 
        event
      )

      success(
        event_id: updated_event.id,
        message: "Event updated in Google Calendar"
      )
    end

    def delete_google_event(service, connection)
      return success(message: "No calendar event to delete") unless booking.calendar_event_id

      service.delete_event(connection.calendar_id, booking.calendar_event_id)
      
      # Clear the stored event ID
      booking.update!(calendar_event_id: nil)

      success(message: "Event deleted from Google Calendar")
    end

    def build_google_event
      event = Google::Apis::CalendarV3::Event.new

      # Basic event details
      event.summary = "Golf at #{booking.course.name}"
      event.description = build_event_description
      event.location = build_event_location

      # Set times
      start_time = Google::Apis::CalendarV3::EventDateTime.new(
        date_time: booking.starts_at.iso8601,
        time_zone: 'America/Denver' # TODO: Use course timezone
      )
      end_time = Google::Apis::CalendarV3::EventDateTime.new(
        date_time: (booking.starts_at + 2.hours).iso8601,
        time_zone: 'America/Denver'
      )
      
      event.start = start_time
      event.end = end_time

      # Add reminder
      reminder = Google::Apis::CalendarV3::EventReminder.new(
        method: 'popup',
        minutes: 60 # 1 hour before
      )
      
      event.reminders = Google::Apis::CalendarV3::Event::Reminders.new(
        use_default: false,
        overrides: [reminder]
      )

      event
    end

    def build_event_description
      description = []
      description << "Golf booking at #{booking.course.name}"
      description << ""
      description << "Confirmation Code: #{booking.confirmation_code}"
      description << "Players: #{booking.players_count}"
      
      if booking.booking_players.any?
        description << ""
        description << "Players:"
        booking.booking_players.each_with_index do |player, index|
          description << "  #{index + 1}. #{player.name}"
        end
      end

      if booking.notes.present?
        description << ""
        description << "Notes: #{booking.notes}"
      end

      description << ""
      description << "View booking: https://app.teetimespro.com/bookings/#{booking.confirmation_code}"
      
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

      location_parts.join(", ")
    end
  end
end