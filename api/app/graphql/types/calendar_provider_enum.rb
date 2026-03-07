module Types
  class CalendarProviderEnum < Types::BaseEnum
    value "GOOGLE", "Google Calendar", value: "google"
    value "APPLE", "Apple Calendar (iCal)", value: "apple"
  end
end