module Marketplace
  module Adapters
    class TeeoffAdapter < BaseAdapter
      BASE_URL = "https://api.teeoff.com/v1".freeze
      DEFAULT_COMMISSION_BPS = 1200 # 12%

      def validate_connection
        if api_key.blank?
          return { valid: false, error: "API key is required" }
        end

        {
          valid: true,
          external_course_id: credentials["facility_id"] || "to_#{connection.course_id}"
        }
      end

      def create_listing(tee_time:, price_cents:, available_spots:)
        payload = {
          facility_id: connection.external_course_id,
          date: tee_time.starts_at.to_date.iso8601,
          time: tee_time.starts_at.strftime("%H:%M"),
          rate_cents: price_cents,
          openings: available_spots,
          holes: tee_time.course&.holes || 18,
          reference_id: tee_time.id.to_s
        }

        # In production: POST to TeeOff API
        # response = post_request("/inventory", payload)
        # response["inventory_id"]

        "to_listing_#{SecureRandom.hex(8)}"
      end

      def update_listing(external_listing_id:, available_spots:, price_cents:)
        payload = {
          openings: available_spots,
          rate_cents: price_cents
        }

        # In production: PATCH to TeeOff API
        # patch_request("/inventory/#{external_listing_id}", payload)

        true
      end

      def remove_listing(external_listing_id)
        # In production: DELETE to TeeOff API
        # delete_request("/inventory/#{external_listing_id}")

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
