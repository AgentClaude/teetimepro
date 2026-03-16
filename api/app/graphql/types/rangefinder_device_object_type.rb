module Types
  class RangefinderDeviceObjectType < BaseObject
    description "A registered rangefinder or GPS device"

    field :id, ID, null: false
    field :device_id, String, null: false
    field :name, String, null: false
    field :device_type, RangefinderDeviceTypeEnum, null: false
    field :status, RangefinderDeviceStatusEnum, null: false
    field :firmware_version, String, null: true
    field :battery_level, Float, null: true
    field :online, Boolean, null: false
    field :last_seen_at, GraphQL::Types::ISO8601DateTime, null: true
    field :metadata, GraphQL::Types::JSON, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    def online
      object.online?
    end
  end
end
