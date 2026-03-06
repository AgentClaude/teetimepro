# frozen_string_literal: true

module Api
  module V1
    class SmsController < BaseController
      skip_before_action :authenticate_user!, only: [:status_callback]

      # POST /api/v1/sms/status_callback
      # Twilio webhook for SMS delivery status updates
      def status_callback
        message_sid = params[:MessageSid]
        message_status = params[:MessageStatus]

        return head :bad_request if message_sid.blank? || message_status.blank?

        sms_message = SmsMessage.find_by(twilio_sid: message_sid)
        return head :not_found unless sms_message

        status_map = {
          "queued" => :queued,
          "sent" => :sent,
          "delivered" => :delivered,
          "failed" => :failed,
          "undelivered" => :undelivered
        }

        new_status = status_map[message_status]
        return head :ok unless new_status

        updates = { status: new_status }
        updates[:delivered_at] = Time.current if new_status == :delivered
        updates[:error_code] = params[:ErrorCode] if params[:ErrorCode].present?
        updates[:error_message] = params[:ErrorMessage]&.truncate(500) if params[:ErrorMessage].present?

        sms_message.update!(updates)

        # Update campaign counters
        Campaigns::UpdateCampaignCountersService.call(sms_message: sms_message)

        head :ok
      end
    end
  end
end
