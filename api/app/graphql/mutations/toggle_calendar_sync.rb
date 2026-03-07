module Mutations
  class ToggleCalendarSync < BaseMutation
    description "Enable or disable calendar sync for a specific provider"

    argument :provider, Types::CalendarProviderEnum, required: true,
             description: "Calendar provider to toggle"
    argument :enabled, Boolean, required: true,
             description: "Whether to enable or disable calendar sync"

    field :connection, Types::CalendarConnectionType, null: true
    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(provider:, enabled:)
      require_auth!

      connection = current_user.calendar_connections.find_by(provider: provider)
      
      unless connection
        return {
          connection: nil,
          success: false,
          errors: ["No #{provider} calendar connection found"]
        }
      end

      if connection.update(enabled: enabled)
        {
          connection: connection,
          success: true,
          errors: []
        }
      else
        {
          connection: nil,
          success: false,
          errors: connection.errors.full_messages
        }
      end
    end
  end
end