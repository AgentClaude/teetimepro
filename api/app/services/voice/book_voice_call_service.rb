module Voice
  class BookVoiceCallService < ApplicationService
    attr_accessor :organization, :tee_time_id, :players_count, :caller_name, :caller_phone

    validates :organization, presence: true
    validates :tee_time_id, presence: true
    validates :players_count, presence: true, numericality: { in: 1..5 }
    validates :caller_name, presence: true
    validates :caller_phone, presence: true

    def call
      return validation_failure(self) unless valid?

      booking = nil
      user = nil
      tee_time = nil

      ActiveRecord::Base.transaction do
        tee_time = find_and_validate_tee_time
        return failure(["Tee time not found or unavailable"]) unless tee_time

        user = find_or_create_user
        return validation_failure(user) unless user.persisted?

        booking = create_pending_booking(tee_time, user)
        return validation_failure(booking) unless booking.persisted?
      end

      success(
        booking: booking,
        booking_id: booking.id,
        confirmation_code: booking.confirmation_code,
        date: tee_time.starts_at.strftime("%Y-%m-%d"),
        formatted_time: tee_time.formatted_time,
        players: booking.players_count,
        price_per_player_cents: tee_time.price_cents || 0,
        total_cents: booking.total_cents,
        course_name: tee_time.course.name
      )

    rescue StandardError => e
      Rails.logger.error "Voice booking creation failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      failure(["Failed to create voice booking: #{e.message}"])
    end

    private

    def find_and_validate_tee_time
      tee_time = TeeTime.joins(tee_sheet: :course)
                       .where(id: tee_time_id, courses: { organization_id: organization.id })
                       .first

      return nil unless tee_time
      return nil unless tee_time.available_spots >= players_count
      return nil unless tee_time.starts_at > Time.current

      tee_time
    end

    def find_or_create_user
      # Split caller name into first/last
      name_parts = caller_name.strip.split(/\s+/)
      first_name = name_parts[0]
      last_name = name_parts.length > 1 ? name_parts[1..].join(" ") : ""

      # Normalize phone number
      normalized_phone = normalize_phone_number(caller_phone)

      # Try to find existing user by phone or email
      user = User.where(organization: organization)
                 .where("phone = ? OR email = ?", normalized_phone, "#{normalized_phone.gsub(/\D/, '')}@voice-booking.local")
                 .first

      unless user
        # Create new user for voice booking
        user = User.new(
          organization: organization,
          email: "#{normalized_phone.gsub(/\D/, '')}@voice-booking.local", # Temporary email
          first_name: first_name,
          last_name: last_name,
          phone: normalized_phone,
          role: "golfer",
          password: SecureRandom.urlsafe_base64(12), # Random password
          confirmed_at: Time.current # Auto-confirm voice booking users
        )
      end

      user
    end

    def create_pending_booking(tee_time, user)
      price_per_player = tee_time.price_cents || 0
      total_cents = price_per_player * players_count

      Booking.new(
        tee_time: tee_time,
        user: user,
        players_count: players_count,
        total_cents: total_cents,
        status: :pending_voice_confirmation,
        notes: "Voice booking - pending confirmation"
      )
    end

    def normalize_phone_number(phone)
      # Remove all non-digit characters
      digits = phone.to_s.gsub(/\D/, '')
      
      # If it's 10 digits, assume US number and add +1
      if digits.length == 10
        "+1#{digits}"
      # If it's 11 digits and starts with 1, add +
      elsif digits.length == 11 && digits.start_with?('1')
        "+#{digits}"
      else
        phone.to_s
      end
    end
  end
end