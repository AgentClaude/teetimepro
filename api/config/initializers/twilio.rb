# frozen_string_literal: true

# Twilio client configuration
# Requires TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, and TWILIO_PHONE_NUMBER env vars

module TwilioConfig
  class << self
    def client
      @client ||= Twilio::REST::Client.new(account_sid, auth_token)
    end

    def from_number
      ENV.fetch("TWILIO_PHONE_NUMBER")
    end

    def account_sid
      ENV.fetch("TWILIO_ACCOUNT_SID")
    end

    def auth_token
      ENV.fetch("TWILIO_AUTH_TOKEN")
    end

    def configured?
      ENV["TWILIO_ACCOUNT_SID"].present? && ENV["TWILIO_AUTH_TOKEN"].present? && ENV["TWILIO_PHONE_NUMBER"].present?
    end
  end
end
