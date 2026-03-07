# frozen_string_literal: true

# Validate environment configuration on boot.
# In development/test: warns about missing optional integrations.
# In production: raises if required vars are missing (fail-fast).

require_relative "../../lib/app_config"

begin
  AppConfig.validate!
rescue AppConfig::ConfigurationError => e
  if Rails.env.production?
    # Hard fail in production — don't start with missing config
    raise
  else
    Rails.logger&.warn("⚠️  AppConfig validation: #{e.message}")
  end
end

# Log config status on boot (no secrets)
Rails.application.config.after_initialize do
  if Rails.env.development?
    status = AppConfig.status
    Rails.logger.info("📋 AppConfig Status:")
    status.each { |key, val| Rails.logger.info("   #{key}: #{val}") }

    unless AppConfig.stripe_configured?
      Rails.logger.info("💡 Stripe not configured — payment features disabled. Set STRIPE_* vars in .env")
    end

    unless AppConfig.twilio_configured?
      Rails.logger.info("💡 Twilio not configured — SMS features disabled. Set TWILIO_* vars in .env")
    end
  end
end
