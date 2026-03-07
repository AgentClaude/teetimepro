module Marketplace
  class SyndicateTeeTimesService < ApplicationService
    attr_accessor :connection

    validates :connection, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Connection is not active"]) unless connection.active?

      adapter = Marketplace::AdapterFactory.for(connection)
      settings = connection.effective_settings

      # Find tee times eligible for syndication
      eligible_tee_times = find_eligible_tee_times
      existing_listing_ids = connection.marketplace_listings
                                       .active_listings
                                       .pluck(:tee_time_id)

      new_tee_times = eligible_tee_times.reject { |tt| existing_listing_ids.include?(tt.id) }
      created_listings = []
      errors = []

      new_tee_times.each do |tee_time|
        listing = create_listing(tee_time, settings, adapter)

        if listing
          created_listings << listing
        else
          errors << "Failed to list tee time #{tee_time.id}"
        end
      end

      # Expire listings for tee times no longer eligible
      expire_stale_listings(eligible_tee_times.map(&:id))

      connection.record_sync!

      success(
        created_count: created_listings.size,
        expired_count: @expired_count || 0,
        errors: errors,
        listings: created_listings
      )
    rescue StandardError => e
      connection.record_error!(e.message)
      failure(["Syndication failed: #{e.message}"])
    end

    private

    def find_eligible_tee_times
      settings = connection.effective_settings
      min_time = Time.current + settings["min_advance_hours"].to_i.hours
      max_time = Time.current + settings["max_advance_days"].to_i.days
      min_spots = settings["min_available_spots"].to_i

      TeeTime.joins(tee_sheet: :course)
             .where(tee_sheets: { course_id: connection.course_id })
             .where(status: [:available, :partially_booked])
             .where(starts_at: min_time..max_time)
             .where("tee_times.max_players - tee_times.booked_players >= ?", min_spots)
             .order(:starts_at)
    end

    def create_listing(tee_time, settings, adapter)
      listed_price = calculate_listed_price(tee_time, settings)
      commission_bps = adapter.commission_rate_bps

      listing = MarketplaceListing.create!(
        marketplace_connection: connection,
        tee_time: tee_time,
        status: :pending,
        listed_price_cents: listed_price,
        listed_price_currency: tee_time.price_currency || "USD",
        commission_rate_bps: commission_bps,
        expires_at: tee_time.starts_at
      )

      # Push to marketplace
      external_id = adapter.create_listing(
        tee_time: tee_time,
        price_cents: listed_price,
        available_spots: tee_time.available_spots
      )

      listing.mark_listed!(external_id) if external_id
      listing
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.warn("Failed to create listing: #{e.message}")
      nil
    rescue StandardError => e
      Rails.logger.warn("Marketplace API error: #{e.message}")
      listing&.update(status: :error, metadata: { error: e.message })
      nil
    end

    def calculate_listed_price(tee_time, settings)
      base_price = tee_time.price_cents || 0
      discount = settings["discount_percent"].to_f

      if discount > 0
        (base_price * (1 - discount / 100.0)).ceil
      else
        base_price
      end
    end

    def expire_stale_listings(eligible_ids)
      stale = connection.marketplace_listings
                        .active_listings
                        .where.not(tee_time_id: eligible_ids)

      @expired_count = stale.count
      stale.update_all(status: :expired)
    end
  end
end
