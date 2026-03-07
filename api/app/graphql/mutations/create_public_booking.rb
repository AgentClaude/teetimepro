module Mutations
  class CreatePublicBooking < BaseMutation
    argument :course_slug, String, required: true
    argument :tee_time_id, ID, required: true
    argument :players_count, Integer, required: true
    argument :customer_name, String, required: true
    argument :customer_email, String, required: true
    argument :customer_phone, String, required: true

    field :booking, Types::BookingType, null: true
    field :errors, [String], null: false

    def resolve(course_slug:, tee_time_id:, players_count:, customer_name:, customer_email:, customer_phone:)
      begin
        # Find course by slug (public, no auth required)
        course = Course.joins(:organization).find_by(slug: course_slug)
        return { booking: nil, errors: ["Course not found"] } unless course
        
        organization = course.organization

        # Find the tee time
        tee_time = TeeTime.joins(tee_sheet: :course)
                          .where(courses: { id: course.id })
                          .find_by(id: tee_time_id)
        return { booking: nil, errors: ["Tee time not found"] } unless tee_time

        # Validate availability
        if tee_time.available_spots < players_count
          return { booking: nil, errors: ["Not enough spots available"] }
        end

        if tee_time.starts_at <= Time.current
          return { booking: nil, errors: ["Cannot book tee times in the past"] }
        end

        # Find or create user (guest golfer)
        user = organization.users.find_or_initialize_by(email: customer_email) do |u|
          name_parts = customer_name.strip.split(' ', 2)
          u.first_name = name_parts[0] || customer_name
          u.last_name = name_parts[1] || ''
          u.phone = customer_phone
          u.role = :golfer
          u.password = SecureRandom.hex(16) # Random password for guest
        end

        # Update user info if existing
        if user.persisted?
          name_parts = customer_name.strip.split(' ', 2)
          user.update!(
            first_name: name_parts[0] || customer_name,
            last_name: name_parts[1] || '',
            phone: customer_phone
          )
        else
          user.save!
        end

        # Calculate total
        rate = tee_time.price_cents || course.default_rate_for(
          tee_time.date,
          tee_time.starts_at
        )&.cents || 0

        total_cents = rate * players_count

        # Create the booking directly (since we can't use auth-required service)
        ActiveRecord::Base.transaction do
          booking = Booking.create!(
            tee_time: tee_time,
            user: user,
            players_count: players_count,
            total_cents: total_cents,
            total_currency: "USD",
            status: :confirmed,
            notes: "Public booking widget"
          )

          # Create booking players
          players_count.times do |i|
            BookingPlayer.create!(
              booking: booking,
              name: i.zero? ? user.full_name : "Player #{i + 1}"
            )
          end

          # Book the spots on the tee time
          tee_time.book_spots!(players_count)

          # Send confirmation email (async, if service exists)
          begin
            Notifications::SendBookingConfirmationService.call(booking: booking)
          rescue StandardError => e
            # Log error but don't fail the booking
            Rails.logger.error "Failed to send confirmation email: #{e.message}"
          end

          { booking: booking, errors: [] }
        end

      rescue ActiveRecord::RecordInvalid => e
        { booking: nil, errors: [e.message] }
      rescue StandardError => e
        { booking: nil, errors: [e.message] }
      end
    end
  end
end