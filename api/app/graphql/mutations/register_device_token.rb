# frozen_string_literal: true

module Mutations
  class RegisterDeviceToken < BaseMutation
    argument :token, String, required: true, description: "Expo push token"
    argument :platform, String, required: true, description: "Device platform (ios or android)"
    argument :device_id, String, required: false, description: "Unique device identifier for dedup"

    field :device_token, Types::DeviceTokenType, null: true
    field :errors, [String], null: false

    def resolve(token:, platform:, device_id: nil)
      result = PushNotifications::RegisterDeviceService.call(
        user: context[:current_user],
        token: token,
        platform: platform,
        device_id: device_id
      )

      if result.success?
        { device_token: result.device_token, errors: [] }
      else
        { device_token: nil, errors: result.errors }
      end
    end
  end
end
