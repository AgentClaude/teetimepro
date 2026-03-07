# frozen_string_literal: true

# AppConfig — Centralized environment configuration and validation
#
# Provides typed accessors for all environment variables with boot-time
# validation. Required vars raise on missing in production; optional vars
# return nil or defaults.
#
# Usage:
#   AppConfig.database_url       # => "postgres://..."
#   AppConfig.stripe_configured? # => true/false
#   AppConfig.validate!          # raises if required vars missing
#
module AppConfig
  class ConfigurationError < StandardError; end

  # Required in ALL environments
  ALWAYS_REQUIRED = %w[
    SECRET_KEY_BASE
    JWT_SECRET_KEY
  ].freeze

  # Required only in production
  PRODUCTION_REQUIRED = %w[
    DATABASE_URL
    SECRET_KEY_BASE
    JWT_SECRET_KEY
    CORS_ORIGINS
    STRIPE_PUBLISHABLE_KEY
    STRIPE_SECRET_KEY
    STRIPE_WEBHOOK_SECRET
    TWILIO_ACCOUNT_SID
    TWILIO_AUTH_TOKEN
    TWILIO_PHONE_NUMBER
    DOMAIN
  ].freeze

  class << self
    # ─── Database ───────────────────────────────────────────────
    def database_url
      ENV["DATABASE_URL"]
    end

    def db_host
      ENV.fetch("DB_HOST", "localhost")
    end

    def db_port
      ENV.fetch("DB_PORT", "5432").to_i
    end

    def db_username
      ENV.fetch("DB_USERNAME", "teetimepro")
    end

    def db_password
      ENV.fetch("DB_PASSWORD", "password")
    end

    def db_name
      ENV.fetch("DB_NAME", "teetimepro_development")
    end

    def db_test_name
      ENV.fetch("DB_TEST_NAME", "teetimepro_test")
    end

    # ─── Redis ──────────────────────────────────────────────────
    def redis_url
      ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
    end

    def sidekiq_redis_url
      ENV.fetch("SIDEKIQ_REDIS_URL", "redis://localhost:6379/1")
    end

    # ─── Rails / Auth ──────────────────────────────────────────
    def secret_key_base
      ENV["SECRET_KEY_BASE"]
    end

    def jwt_secret_key
      ENV["JWT_SECRET_KEY"]
    end

    def cors_origins
      ENV.fetch("CORS_ORIGINS", "http://localhost:3004").split(",").map(&:strip)
    end

    def rails_env
      ENV.fetch("RAILS_ENV", "development")
    end

    def rails_log_level
      ENV.fetch("RAILS_LOG_LEVEL", "info")
    end

    # ─── Stripe ─────────────────────────────────────────────────
    def stripe_publishable_key
      ENV["STRIPE_PUBLISHABLE_KEY"]
    end

    def stripe_secret_key
      ENV["STRIPE_SECRET_KEY"]
    end

    def stripe_webhook_secret
      ENV["STRIPE_WEBHOOK_SECRET"]
    end

    def stripe_configured?
      stripe_publishable_key.present? && stripe_secret_key.present?
    end

    # ─── Twilio ─────────────────────────────────────────────────
    def twilio_account_sid
      ENV["TWILIO_ACCOUNT_SID"]
    end

    def twilio_auth_token
      ENV["TWILIO_AUTH_TOKEN"]
    end

    def twilio_phone_number
      ENV["TWILIO_PHONE_NUMBER"]
    end

    def twilio_configured?
      twilio_account_sid.present? && twilio_auth_token.present? && twilio_phone_number.present?
    end

    # ─── Deepgram / Voice ──────────────────────────────────────
    def deepgram_api_key
      ENV["DEEPGRAM_API_KEY"]
    end

    def deepgram_configured?
      deepgram_api_key.present?
    end

    def voice_agent_ws_url
      ENV["VOICE_AGENT_WS_URL"]
    end

    def teetimepro_api_key
      ENV["TEETIMEPRO_API_KEY"]
    end

    # ─── Frontend ──────────────────────────────────────────────
    def vite_api_url
      ENV.fetch("VITE_API_URL", "http://localhost:3003")
    end

    def domain
      ENV["DOMAIN"]
    end

    # ─── Validation ────────────────────────────────────────────

    # Validate all required env vars are present. Raises ConfigurationError
    # with a list of missing vars.
    def validate!
      missing = required_vars.select { |var| ENV[var].blank? }

      return if missing.empty?

      raise ConfigurationError,
            "Missing required environment variables:\n" \
            "  #{missing.join("\n  ")}\n\n" \
            "See .env.example (development) or .env.production.example (production) for reference."
    end

    # Returns a hash summarizing config status (safe for logging — no secrets)
    def status
      {
        environment: rails_env,
        database: database_url.present? ? "configured (URL)" : "configured (host: #{db_host})",
        redis: redis_url,
        stripe: stripe_configured? ? "configured" : "not configured",
        twilio: twilio_configured? ? "configured" : "not configured",
        deepgram: deepgram_configured? ? "configured" : "not configured",
        cors_origins: cors_origins,
        domain: domain || "(not set)"
      }
    end

    private

    def required_vars
      if Rails.env.production?
        PRODUCTION_REQUIRED
      else
        ALWAYS_REQUIRED
      end
    end
  end
end
