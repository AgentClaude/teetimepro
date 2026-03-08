module Bookings
  class CreateWalkOnBookingService < ApplicationService
    attr_accessor :organization, :staff_user, :tee_time_id, :course_id,
                  :players_count, :guest_name, :guest_email, :guest_phone,
                  :walk_on_notes, :user_id

    validates :staff_user, :players_count, :guest_name, presence: true
    validate :staff_has_permission
    validate :tee_time_or_course_present

    def call
      return validation_failure(self) unless valid?

      tee_time = find_or_assign_tee_time
      return tee_time unless tee_time.is_a?(TeeTime)

      # Check availability
      if tee_time.available_spots < players_count
        return failure(["Not enough spots available. #{tee_time.available_spots} spot(s) remaining."])
      end

      ActiveRecord::Base.transaction do
        # Find or create guest user if user_id not provided
        booking_user = resolve_booking_user

        booking = Booking.create!(
          tee_time: tee_time,
          user: booking_user,
          players_count: players_count,
          total_cents: calculate_total(tee_time),
          total_currency: "USD",
          status: :confirmed,
          booking_type: :walk_on,
          guest_name: guest_name,
          guest_email: guest_email,
          guest_phone: guest_phone,
          created_by: staff_user,
          walk_on_notes: walk_on_notes,
          notes: "Walk-on booking created by #{staff_user.full_name}"
        )

        # Create booking players
        create_booking_players(booking)

        # Book the spots on the tee time
        tee_time.book_spots!(players_count)

        # Broadcast real-time notification
        broadcast_walk_on_notification(booking)

        # Send SMS confirmation if phone provided
        if guest_phone.present?
          Notifications::SendBookingConfirmationService.call(booking: booking)
        end

        # Dispatch webhook
        Webhooks::DispatchEventService.call(
          organization: organization,
          event_type: "booking.walk_on_created",
          payload: build_webhook_payload(booking)
        )

        success(booking: booking, tee_time: tee_time)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end

    private

    def staff_has_permission
      return if staff_user.blank?

      unless staff_user.pro_shop? || staff_user.manager? || staff_user.admin? || staff_user.owner?
        errors.add(:staff_user, "does not have permission to create walk-on bookings")
      end
    end

    def tee_time_or_course_present
      if tee_time_id.blank? && course_id.blank?
        errors.add(:base, "Either tee_time_id or course_id must be provided")
      end
    end

    def find_or_assign_tee_time
      if tee_time_id.present?
        tee_time = TeeTime.joins(tee_sheet: :course)
                          .where(courses: { organization_id: organization.id })
                          .find_by(id: tee_time_id)
        return failure(["Tee time not found"]) unless tee_time
        tee_time
      else
        # Find next available tee time for the course today
        course = Course.where(organization_id: organization.id).find_by(id: course_id)
        return failure(["Course not found"]) unless course

        tee_time = TeeTime.joins(tee_sheet: :course)
                          .where(courses: { id: course.id })
                          .where(tee_sheets: { date: Date.current })
                          .where("tee_times.starts_at > ?", Time.current)
                          .available_for(players_count)
                          .order(:starts_at)
                          .first

        return failure(["No available tee times found today for #{players_count} player(s)"]) unless tee_time
        tee_time
      end
    end

    def resolve_booking_user
      if user_id.present?
        User.find(user_id)
      else
        # For walk-ons without an account, use the staff user as the booking owner
        # The guest info is stored on the booking itself
        staff_user
      end
    end

    def calculate_total(tee_time)
      rate = tee_time.price_cents || tee_time.course.default_rate_for(
        tee_time.date,
        tee_time.starts_at
      )&.cents || 0

      rate * players_count
    end

    def create_booking_players(booking)
      # First player is the guest
      BookingPlayer.create!(
        booking: booking,
        name: guest_name,
        email: guest_email,
        phone: guest_phone
      )

      # Additional players
      (players_count - 1).times do |i|
        BookingPlayer.create!(
          booking: booking,
          name: "Guest #{i + 2}"
        )
      end
    end

    def broadcast_walk_on_notification(booking)
      ActionCable.server.broadcast(
        "notifications_#{organization.id}",
        {
          type: "booking.walk_on_created",
          booking: {
            id: booking.id,
            confirmation_code: booking.confirmation_code,
            status: booking.status,
            booking_type: booking.booking_type,
            players_count: booking.players_count,
            guest_name: booking.guest_name,
            tee_time: booking.tee_time.formatted_time,
            date: booking.tee_time.date.iso8601,
            course_name: booking.course.name,
            created_by: staff_user.full_name
          },
          timestamp: Time.current.iso8601
        }
      )
    end

    def build_webhook_payload(booking)
      {
        id: booking.id,
        type: "walk_on_booking",
        attributes: {
          confirmation_code: booking.confirmation_code,
          status: booking.status,
          booking_type: booking.booking_type,
          players_count: booking.players_count,
          guest_name: booking.guest_name,
          guest_email: booking.guest_email,
          guest_phone: booking.guest_phone,
          total_cents: booking.total_cents,
          walk_on_notes: booking.walk_on_notes,
          created_at: booking.created_at.iso8601
        },
        tee_time: {
          id: booking.tee_time.id,
          starts_at: booking.tee_time.starts_at.iso8601,
          date: booking.tee_time.date.iso8601
        },
        course: {
          id: booking.course.id,
          name: booking.course.name
        },
        created_by: {
          id: staff_user.id,
          name: staff_user.full_name
        },
        timestamp: Time.current.iso8601,
        organization_id: organization.id
      }
    end
  end
end
