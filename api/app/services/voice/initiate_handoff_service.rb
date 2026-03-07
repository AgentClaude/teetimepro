module Voice
  class InitiateHandoffService < ApplicationService
    attr_accessor :organization, :call_sid, :caller_phone, :caller_name, :reason, :reason_detail, :voice_call_log_id

    validates :organization, presence: true
    validates :call_sid, presence: true
    validates :caller_phone, presence: true
    validates :reason, presence: true, inclusion: { in: VoiceHandoff.reasons.keys }

    def call
      return validation_failure(self) unless valid?

      # Check if handoff already exists for this call
      existing_handoff = VoiceHandoff.find_by(call_sid: call_sid)
      if existing_handoff
        return success(
          handoff: existing_handoff,
          transfer_number: transfer_number,
          already_exists: true
        )
      end

      handoff = nil
      
      ActiveRecord::Base.transaction do
        handoff = create_handoff
        return validation_failure(handoff) unless handoff.persisted?
      end

      success(
        handoff: handoff,
        handoff_id: handoff.id,
        transfer_number: transfer_number,
        created: true
      )

    rescue StandardError => e
      Rails.logger.error "Voice handoff creation failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      failure(["Failed to create handoff: #{e.message}"])
    end

    private

    def create_handoff
      voice_call_log = find_voice_call_log

      VoiceHandoff.create!(
        organization: organization,
        voice_call_log: voice_call_log,
        call_sid: call_sid,
        caller_phone: normalize_phone_number(caller_phone),
        caller_name: caller_name&.strip&.presence,
        reason: reason,
        reason_detail: reason_detail&.strip&.presence,
        transfer_to: transfer_number,
        status: 'pending',
        started_at: Time.current
      )
    end

    def find_voice_call_log
      return nil unless voice_call_log_id.present?
      
      VoiceCallLog.find_by(id: voice_call_log_id, organization: organization)
    end

    def transfer_number
      @transfer_number ||= organization.voice_config&.dig('handoff_phone_number') || 
                          ENV.fetch('HANDOFF_PHONE_NUMBER', '+1234567890')
    end

    def normalize_phone_number(phone)
      # Remove all non-digit characters and ensure it starts with +1 for US numbers
      digits = phone.to_s.gsub(/\D/, '')
      
      # If it's 10 digits, assume US number and add +1
      if digits.length == 10
        "+1#{digits}"
      # If it's 11 digits and starts with 1, add +
      elsif digits.length == 11 && digits.start_with?('1')
        "+#{digits}"
      else
        phone.to_s
      end
    end
  end
end