# frozen_string_literal: true

module Types
  class BlockTypeEnum < Types::BaseEnum
    value "MAINTENANCE", "Maintenance or course work", value: "maintenance"
    value "EVENT", "Special event or tournament", value: "event"
    value "WEATHER", "Weather-related closure", value: "weather"
    value "OTHER", "Other reason", value: "other"
  end
end
