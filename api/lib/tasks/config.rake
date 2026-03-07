# frozen_string_literal: true

namespace :config do
  desc "Validate environment configuration"
  task validate: :environment do
    puts "🔍 Validating environment configuration..."
    puts

    begin
      AppConfig.validate!
      puts "✅ All required environment variables are set."
    rescue AppConfig::ConfigurationError => e
      puts "❌ #{e.message}"
      exit 1
    end

    puts
    puts "📋 Configuration Status:"
    AppConfig.status.each do |key, value|
      puts "   #{key}: #{value}"
    end
    puts
  end

  desc "Show which env vars are set (no values — safe for logs)"
  task audit: :environment do
    puts "🔍 Environment Variable Audit"
    puts "   Environment: #{AppConfig.rails_env}"
    puts

    all_vars = (AppConfig::ALWAYS_REQUIRED + AppConfig::PRODUCTION_REQUIRED).uniq.sort
    all_vars.each do |var|
      status = ENV[var].present? ? "✅ set" : "⬜ not set"
      puts "   #{var}: #{status}"
    end

    # Also check optional vars
    optional = %w[
      DEEPGRAM_API_KEY
      VOICE_AGENT_WS_URL
      TEETIMEPRO_API_KEY
      VITE_API_URL
      RAILS_LOG_LEVEL
      REDIS_URL
      SIDEKIQ_REDIS_URL
    ]

    puts
    puts "   Optional:"
    optional.each do |var|
      status = ENV[var].present? ? "✅ set" : "⬜ not set"
      puts "   #{var}: #{status}"
    end
    puts
  end
end
