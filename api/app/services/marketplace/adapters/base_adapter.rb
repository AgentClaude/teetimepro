module Marketplace
  module Adapters
    class BaseAdapter
      attr_reader :connection

      def initialize(connection)
        @connection = connection
      end

      # Validate the marketplace API credentials
      # Returns { valid: true/false, external_course_id: "...", error: "..." }
      def validate_connection
        raise NotImplementedError
      end

      # Push a tee time listing to the marketplace
      # Returns the external listing ID
      def create_listing(tee_time:, price_cents:, available_spots:)
        raise NotImplementedError
      end

      # Update availability for an existing listing
      def update_listing(external_listing_id:, available_spots:, price_cents:)
        raise NotImplementedError
      end

      # Remove a single listing from the marketplace
      def remove_listing(external_listing_id)
        raise NotImplementedError
      end

      # Remove multiple listings from the marketplace
      def remove_listings(external_listing_ids)
        external_listing_ids.each { |id| remove_listing(id) }
      end

      # Default commission rate in basis points
      def commission_rate_bps
        raise NotImplementedError
      end

      protected

      def credentials
        connection.credentials
      end

      def api_key
        credentials["api_key"]
      end

      def api_secret
        credentials["api_secret"]
      end

      def base_url
        raise NotImplementedError
      end

      def http_client
        @http_client ||= begin
          uri = URI(base_url)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.open_timeout = 10
          http.read_timeout = 30
          http
        end
      end
    end
  end
end
