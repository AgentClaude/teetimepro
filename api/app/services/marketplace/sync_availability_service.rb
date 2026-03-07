module Marketplace
  class SyncAvailabilityService < ApplicationService
    attr_accessor :connection

    validates :connection, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Connection is not active"]) unless connection.active?

      adapter = Marketplace::AdapterFactory.for(connection)
      active_listings = connection.marketplace_listings.active_listings.includes(:tee_time)

      updated_count = 0
      removed_count = 0
      errors = []

      active_listings.find_each do |listing|
        tee_time = listing.tee_time

        if tee_time_no_longer_available?(tee_time)
          # Remove from marketplace
          begin
            adapter.remove_listing(listing.external_listing_id)
            listing.mark_expired!
            removed_count += 1
          rescue StandardError => e
            errors << "Failed to remove listing #{listing.id}: #{e.message}"
          end
        elsif availability_changed?(listing, tee_time)
          # Update availability on marketplace
          begin
            adapter.update_listing(
              external_listing_id: listing.external_listing_id,
              available_spots: tee_time.available_spots,
              price_cents: listing.listed_price_cents
            )
            updated_count += 1
          rescue StandardError => e
            errors << "Failed to update listing #{listing.id}: #{e.message}"
          end
        end
      end

      connection.record_sync!

      success(
        updated_count: updated_count,
        removed_count: removed_count,
        errors: errors
      )
    rescue StandardError => e
      connection.record_error!(e.message)
      failure(["Availability sync failed: #{e.message}"])
    end

    private

    def tee_time_no_longer_available?(tee_time)
      tee_time.fully_booked? || tee_time.blocked? || tee_time.maintenance? ||
        tee_time.starts_at <= Time.current + connection.effective_settings["min_advance_hours"].to_i.hours
    end

    def availability_changed?(listing, tee_time)
      # Check if spots changed since last sync
      previous_spots = listing.metadata["last_synced_spots"]
      previous_spots.nil? || previous_spots != tee_time.available_spots
    end
  end
end
