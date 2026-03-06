# frozen_string_literal: true

class SendSmsJob < ApplicationJob
  queue_as :sms

  # Respect Twilio rate limits
  retry_on Twilio::REST::RestException, wait: 5.seconds, attempts: 3

  def perform(sms_message_id)
    sms_message = SmsMessage.find(sms_message_id)
    Campaigns::SendSmsService.call(sms_message: sms_message)
  end
end
