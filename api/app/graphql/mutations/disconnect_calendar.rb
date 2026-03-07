module Mutations
  class DisconnectCalendar < BaseMutation
    description "Disconnect a calendar provider from user's account"

    argument :provider, Types::CalendarProviderEnum, required: true,
             description: "Calendar provider to disconnect"

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(provider:)
      require_auth!

      connection = current_user.calendar_connections.find_by(provider: provider)
      
      unless connection
        return {
          success: false,
          errors: ["No #{provider} calendar connection found"]
        }
      end

      if connection.destroy
        {
          success: true,
          errors: []
        }
      else
        {
          success: false,
          errors: connection.errors.full_messages
        }
      end
    end
  end
end