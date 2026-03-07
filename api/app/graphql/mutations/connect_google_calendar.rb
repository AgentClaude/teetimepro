module Mutations
  class ConnectGoogleCalendar < BaseMutation
    description "Connect user's Google Calendar for booking sync"

    argument :authorization_code, String, required: true,
             description: "Authorization code from Google OAuth flow"

    field :connection, Types::CalendarConnectionType, null: true
    field :calendar_name, String, null: true
    field :errors, [String], null: false

    def resolve(authorization_code:)
      require_auth!

      result = Calendars::GoogleAuthService.call(
        user: current_user,
        authorization_code: authorization_code
      )

      if result.success?
        {
          connection: result.connection,
          calendar_name: result.calendar_name,
          errors: []
        }
      else
        {
          connection: nil,
          calendar_name: nil,
          errors: result.errors
        }
      end
    end
  end
end