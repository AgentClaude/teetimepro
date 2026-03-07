module Marketplace
  class HandleBookingService < ApplicationService
    attr_accessor :connection, :external_listing_id, :external_booking_id,
                  :golfer_name, :golfer_email, :golfer_phone, :players_count

    validates :connection, :external_listing_id, :players_count, presence: true
    validates :golfer_name, presence: true

    def call
      return validation_failure(self) unless valid?

      listing = connection.marketplace_listings.find_by(
        external_listing_id: external_listing_id,
        status: :listed
      )

      return failure(["Listing not found or no longer available"]) unless listing
      return failure(["Not enough spots available"]) unless spots_available?(listing)

      ActiveRecord::Base.transaction do
        # Create or find user for the golfer
        user = find_or_create_marketplace_user

        # Create the booking via the standard booking service
        booking_result = Bookings::CreateBookingService.call(
          user: user,
          tee_time: listing.tee_time,
          players_count: players_count,
          notes: "Marketplace booking via #{connection.provider_label} (#{external_booking_id})",
          skip_payment: true # Payment handled by marketplace
        )

        unless booking_result.success?
          return failure(booking_result.errors)
        end

        # Update listing status
        listing.mark_booked!
        listing.update!(metadata: listing.metadata.merge(
          "external_booking_id" => external_booking_id,
          "booking_id" => booking_result.data[:booking].id
        ))

        # Dispatch webhook for marketplace booking
        Webhooks::DispatchEventService.call(
          organization: connection.organization,
          event_type: "booking.marketplace_created",
          payload: {
            booking_id: booking_result.data[:booking].id,
            marketplace: connection.provider,
            external_booking_id: external_booking_id,
            tee_time: listing.tee_time.starts_at.iso8601,
            players: players_count
          }
        )

        success(
          booking: booking_result.data[:booking],
          listing: listing
        )
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end

    private

    def spots_available?(listing)
      listing.tee_time.available_spots >= players_count
    end

    def find_or_create_marketplace_user
      return User.find_by(email: golfer_email) if golfer_email.present? &&
                                                    User.exists?(email: golfer_email)

      User.create!(
        email: golfer_email || "marketplace+#{SecureRandom.hex(8)}@teetimespro.com",
        name: golfer_name,
        phone: golfer_phone,
        organization: connection.organization,
        role: :golfer,
        password: SecureRandom.urlsafe_base64(32),
        marketplace_source: connection.provider
      )
    end
  end
end
