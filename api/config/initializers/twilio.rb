# frozen_string_literal: true

# Twilio client configuration
# Uses AppConfig for centralized env var access

module TwilioConfig
  class << self
    def client
      @client ||= Twilio::REST::Client.new(account_sid, auth_token)
    end

    def from_number
      AppConfig.twilio_phone_number
    end

    def account_sid
      AppConfig.twilio_account_sid
    end

    def auth_token
      AppConfig.twilio_auth_token
    end

    def configured?
      AppConfig.twilio_configured?
    end
  end
end
