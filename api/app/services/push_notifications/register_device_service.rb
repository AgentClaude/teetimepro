# frozen_string_literal: true

module PushNotifications
  class RegisterDeviceService < ApplicationService
    attr_accessor :user, :token, :platform, :device_id

    validates :user, presence: true
    validates :token, presence: true
    validates :platform, presence: true, inclusion: { in: %w[ios android] }

    def call
      return validation_failure(self) unless valid?

      device_token = find_or_initialize_token

      device_token.assign_attributes(
        user: user,
        organization: user.organization,
        platform: platform,
        device_id: device_id,
        active: true,
        last_used_at: Time.current
      )

      if device_token.save
        # Deactivate any other tokens with the same device_id for this user
        deactivate_old_tokens(device_token) if device_id.present?

        success(device_token: device_token)
      else
        failure(device_token.errors.full_messages)
      end
    end

    private

    def find_or_initialize_token
      DeviceToken.find_or_initialize_by(token: token)
    end

    def deactivate_old_tokens(current_token)
      DeviceToken
        .where(user: user, device_id: device_id)
        .where.not(id: current_token.id)
        .update_all(active: false)
    end
  end
end
