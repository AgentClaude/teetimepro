module Types
  class RangefinderDeviceStatusEnum < BaseEnum
    description "Status of a rangefinder device"

    value "ACTIVE", "Device is active", value: "active"
    value "INACTIVE", "Device is inactive", value: "inactive"
    value "MAINTENANCE", "Device is under maintenance", value: "maintenance"
    value "RETIRED", "Device is retired", value: "retired"
  end
end
