# frozen_string_literal: true

require "rails_helper"
require_relative "../../lib/app_config"

RSpec.describe AppConfig do
  describe ".database accessors" do
    it "returns db_host with default" do
      allow(ENV).to receive(:fetch).with("DB_HOST", "localhost").and_return("db-server")
      expect(described_class.db_host).to eq("db-server")
    end

    it "returns db_port as integer" do
      allow(ENV).to receive(:fetch).with("DB_PORT", "5432").and_return("5433")
      expect(described_class.db_port).to eq(5433)
    end
  end

  describe ".redis accessors" do
    it "returns redis_url with default" do
      allow(ENV).to receive(:fetch).with("REDIS_URL", "redis://localhost:6379/0").and_return("redis://redis:6379/0")
      expect(described_class.redis_url).to eq("redis://redis:6379/0")
    end

    it "returns sidekiq_redis_url with default" do
      allow(ENV).to receive(:fetch).with("SIDEKIQ_REDIS_URL", "redis://localhost:6379/1").and_return("redis://redis:6379/1")
      expect(described_class.sidekiq_redis_url).to eq("redis://redis:6379/1")
    end
  end

  describe ".cors_origins" do
    it "splits comma-separated origins" do
      allow(ENV).to receive(:fetch).with("CORS_ORIGINS", "http://localhost:3004")
        .and_return("https://app.example.com, https://admin.example.com")
      expect(described_class.cors_origins).to eq(["https://app.example.com", "https://admin.example.com"])
    end

    it "returns single origin as array" do
      allow(ENV).to receive(:fetch).with("CORS_ORIGINS", "http://localhost:3004")
        .and_return("http://localhost:3004")
      expect(described_class.cors_origins).to eq(["http://localhost:3004"])
    end
  end

  describe ".stripe_configured?" do
    it "returns true when both keys are set" do
      allow(ENV).to receive(:[]).with("STRIPE_PUBLISHABLE_KEY").and_return("pk_test_xxx")
      allow(ENV).to receive(:[]).with("STRIPE_SECRET_KEY").and_return("sk_test_xxx")
      expect(described_class.stripe_configured?).to be true
    end

    it "returns false when keys are missing" do
      allow(ENV).to receive(:[]).with("STRIPE_PUBLISHABLE_KEY").and_return(nil)
      allow(ENV).to receive(:[]).with("STRIPE_SECRET_KEY").and_return(nil)
      expect(described_class.stripe_configured?).to be false
    end
  end

  describe ".twilio_configured?" do
    it "returns true when all Twilio vars are set" do
      allow(ENV).to receive(:[]).with("TWILIO_ACCOUNT_SID").and_return("ACxxx")
      allow(ENV).to receive(:[]).with("TWILIO_AUTH_TOKEN").and_return("token")
      allow(ENV).to receive(:[]).with("TWILIO_PHONE_NUMBER").and_return("+15551234567")
      expect(described_class.twilio_configured?).to be true
    end

    it "returns false when any Twilio var is missing" do
      allow(ENV).to receive(:[]).with("TWILIO_ACCOUNT_SID").and_return("ACxxx")
      allow(ENV).to receive(:[]).with("TWILIO_AUTH_TOKEN").and_return(nil)
      allow(ENV).to receive(:[]).with("TWILIO_PHONE_NUMBER").and_return("+15551234567")
      expect(described_class.twilio_configured?).to be false
    end
  end

  describe ".validate!" do
    context "in test/development environment" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("test"))
      end

      it "raises when SECRET_KEY_BASE is missing" do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("SECRET_KEY_BASE").and_return(nil)
        allow(ENV).to receive(:[]).with("JWT_SECRET_KEY").and_return("present")

        expect { described_class.validate! }.to raise_error(
          AppConfig::ConfigurationError,
          /SECRET_KEY_BASE/
        )
      end

      it "raises when JWT_SECRET_KEY is missing" do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("SECRET_KEY_BASE").and_return("present")
        allow(ENV).to receive(:[]).with("JWT_SECRET_KEY").and_return(nil)

        expect { described_class.validate! }.to raise_error(
          AppConfig::ConfigurationError,
          /JWT_SECRET_KEY/
        )
      end

      it "does not raise when all required vars are present" do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("SECRET_KEY_BASE").and_return("secret")
        allow(ENV).to receive(:[]).with("JWT_SECRET_KEY").and_return("jwt-secret")

        expect { described_class.validate! }.not_to raise_error
      end
    end

    context "in production environment" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
      end

      it "raises with all missing production vars listed" do
        # Stub all production required vars as blank
        AppConfig::PRODUCTION_REQUIRED.each do |var|
          allow(ENV).to receive(:[]).with(var).and_return(nil)
        end

        expect { described_class.validate! }.to raise_error(AppConfig::ConfigurationError) do |error|
          AppConfig::PRODUCTION_REQUIRED.each do |var|
            expect(error.message).to include(var)
          end
        end
      end
    end
  end

  describe ".status" do
    it "returns a hash with safe config summary" do
      status = described_class.status
      expect(status).to be_a(Hash)
      expect(status).to have_key(:environment)
      expect(status).to have_key(:stripe)
      expect(status).to have_key(:twilio)
      expect(status).to have_key(:deepgram)
      expect(status).to have_key(:cors_origins)
    end

    it "does not include secret values" do
      status = described_class.status
      status_string = status.values.map(&:to_s).join(" ")
      # Should not contain actual secret values
      expect(status_string).not_to include("sk_")
      expect(status_string).not_to include("SECRET")
    end
  end
end
