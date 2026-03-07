module Marketplace
  module Adapters
    class GolfnowAdapter < BaseAdapter
      BASE_URL = "https://api.golfnow.com/v2".freeze
      DEFAULT_COMMISSION_BPS = 1500 # 15%

      def validate_connection
        # In production, this would call GolfNow's API to verify credentials
        # and look up the course by external ID
        if api_key.blank?
          return { valid: false, error: "API key is required" }
        end

        # Simulate API validation (replace with real API call in production)
        {
          valid: true,
          external_course_id: credentials["course_id"] || "gn_#{connection.course_id}"
        }
      end

      def create_listing(tee_time:, price_cents:, available_spots:)
        payload = {
          course_id: connection.external_course_id,
          tee_time: tee_time.starts_at.iso8601,
          price: price_cents / 100.0,
          available_spots: available_spots,
          holes: tee_time.course&.holes || 18,
          includes_cart: false, # Could be configurable
          source_id: tee_time.id.to_s
        }

        # In production: POST to GolfNow API
        # response = post_request("/listings", payload)
        # response["listing_id"]

        # Simulated response
        "gn_listing_#{SecureRandom.hex(8)}"
      end

      def update_listing(external_listing_id:, available_spots:, price_cents:)
        payload = {
          available_spots: available_spots,
          price: price_cents / 100.0
        }

        # In production: PUT to GolfNow API
        # put_request("/listings/#{external_listing_id}", payload)

        true
      end

      def remove_listing(external_listing_id)
        # In production: DELETE to GolfNow API
        # delete_request("/listings/#{external_listing_id}")

        true
      end

      def commission_rate_bps
        credentials["commission_bps"]&.to_i || DEFAULT_COMMISSION_BPS
      end

      private

      def base_url
        BASE_URL
      end
    end
  end
end
