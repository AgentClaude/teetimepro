# frozen_string_literal: true

module Campaigns
  class SendSmsService < ApplicationService
    attr_accessor :sms_message

    validates :sms_message, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure("Message already sent") if sms_message.terminal?

      begin
        twilio_message = TwilioConfig.client.messages.create(
          from: TwilioConfig.from_number,
          to: sms_message.to_phone,
          body: sms_message.sms_campaign.message_body,
          status_callback: status_callback_url
        )

        sms_message.update!(
          twilio_sid: twilio_message.sid,
          status: :queued,
          sent_at: Time.current
        )

        UpdateCampaignCountersService.call(sms_message: sms_message)

        success(sms_message: sms_message)
      rescue Twilio::REST::RestException => e
        sms_message.update!(
          status: :failed,
          error_code: e.code.to_s,
          error_message: e.message.truncate(500)
        )

        UpdateCampaignCountersService.call(sms_message: sms_message)

        failure("Twilio error: #{e.message}")
      end
    end

    private

    def status_callback_url
      base_url = ENV.fetch("APP_BASE_URL", "https://api.teetimepro.com")
      "#{base_url}/api/v1/sms/status_callback"
    end
  end
end
