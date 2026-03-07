module Api
  module V1
    module Recordings
      class WebhookController < ApplicationController
        skip_before_action :verify_authenticity_token
        skip_before_action :authenticate_user!

        def create
          Rails.logger.info "Received Twilio recording webhook: #{webhook_params.inspect}"

          # In a real implementation, we would:
          # 1. Verify the Twilio signature for security
          # 2. Extract the organization from the webhook data or request path
          
          # For now, we'll find the organization based on the call_sid
          call_sid = webhook_params['CallSid']
          voice_call_log = VoiceCallLog.find_by(call_sid: call_sid)
          
          unless voice_call_log
            Rails.logger.error "No voice call log found for CallSid: #{call_sid}"
            return render json: { error: 'Voice call log not found' }, status: :not_found
          end

          organization = voice_call_log.organization

          result = Recordings::StoreRecordingService.call(
            webhook_data: webhook_params.to_h,
            organization: organization
          )

          if result.success?
            Rails.logger.info "Successfully stored recording: #{result.recording.id}"
            render json: { 
              status: 'success',
              recording_id: result.recording.id,
              message: 'Recording stored successfully'
            }
          else
            Rails.logger.error "Failed to store recording: #{result.error_messages}"
            render json: { 
              status: 'error',
              errors: result.errors 
            }, status: :unprocessable_entity
          end
        end

        private

        def webhook_params
          params.permit(
            :CallSid,
            :RecordingSid,
            :RecordingUrl,
            :RecordingStatus,
            :RecordingDuration,
            :RecordingChannels,
            :RecordingStartTime,
            :RecordingSource,
            :RecordingSize
          )
        end

        # TODO: Implement Twilio signature verification
        # def verify_twilio_signature
        #   signature = request.headers['HTTP_X_TWILIO_SIGNATURE']
        #   url = request.original_url
        #   body = request.raw_post
        #   
        #   twilio_auth_token = Rails.application.credentials.twilio[:auth_token]
        #   validator = Twilio::Security::RequestValidator.new(twilio_auth_token)
        #   
        #   unless validator.validate(url, body, signature)
        #     render json: { error: 'Invalid signature' }, status: :unauthorized
        #   end
        # end
      end
    end
  end
end