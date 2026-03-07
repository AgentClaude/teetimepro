class Rack::Attack
  # Enable rate limiting middleware
  enabled = Rails.env.production? || Rails.env.staging? || ENV["RACK_ATTACK_ENABLED"] == "true"

  if enabled
    # Store in Redis
    cache.store = Redis.new(url: AppConfig.redis_url)

    # Define API key extractor
    def self.api_key_from_request(req)
      # Extract API key from Authorization header: "Bearer tp_xxxxx"
      auth_header = req.env["HTTP_AUTHORIZATION"]
      return nil unless auth_header&.start_with?("Bearer tp_")

      auth_header.split(" ").last
    end

    # Throttle API requests by API key
    throttle("api/v1/requests", limit: 1000, period: 1.hour) do |req|
      next unless req.path.start_with?("/api/v1/")
      api_key_from_request(req)
    end

    # More aggressive limit for creation endpoints
    throttle("api/v1/writes", limit: 100, period: 1.hour) do |req|
      if req.path.start_with?("/api/v1/") && %w[POST PUT PATCH DELETE].include?(req.env["REQUEST_METHOD"])
        api_key_from_request(req)
      end
    end

    # Per-minute burst protection
    throttle("api/v1/burst", limit: 60, period: 1.minute) do |req|
      next unless req.path.start_with?("/api/v1/")
      api_key_from_request(req)
    end

    # IP-based fallback for requests without API keys
    throttle("api/v1/ip", limit: 50, period: 1.hour) do |req|
      if req.path.start_with?("/api/v1/") && !api_key_from_request(req)
        req.ip
      end
    end

    # Custom response for rate limited requests
    self.throttled_responder = lambda do |env|
      retry_after = (env["rack.attack.match_data"] || {})[:period]
      
      [
        429,
        {
          "Content-Type" => "application/json",
          "Retry-After" => retry_after.to_s
        },
        [{
          error: "Rate limit exceeded. Try again in #{retry_after} seconds.",
          code: "rate_limit_exceeded"
        }.to_json]
      ]
    end

    # Track rate limited requests
    ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |name, start, finish, request_id, payload|
      Rails.logger.warn "API Rate limit exceeded for #{payload[:request].env['rack.attack.throttle_data']}"
    end
  end
end
