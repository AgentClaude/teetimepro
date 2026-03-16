# frozen_string_literal: true

module Mutations
  class UnregisterDeviceToken < BaseMutation
    argument :token, String, required: true, description: "Expo push token to unregister"

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(token:)
      result = PushNotifications::UnregisterDeviceService.call(
        user: context[:current_user],
        token: token
      )

      if result.success?
        { success: result.deactivated, errors: [] }
      else
        { success: false, errors: result.errors }
      end
    end
  end
end
