# frozen_string_literal: true

module PushNotifications
  class UnregisterDeviceService < ApplicationService
    attr_accessor :user, :token

    validates :user, presence: true
    validates :token, presence: true

    def call
      return validation_failure(self) unless valid?

      device_token = DeviceToken.find_by(token: token, user: user)

      if device_token
        device_token.deactivate!
        success(device_token: device_token, deactivated: true)
      else
        success(device_token: nil, deactivated: false)
      end
    end
  end
end
