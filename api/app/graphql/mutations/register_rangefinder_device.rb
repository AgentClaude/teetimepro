module Mutations
  class RegisterRangefinderDevice < BaseMutation
    argument :device_id, String, required: true
    argument :name, String, required: true
    argument :device_type, Types::RangefinderDeviceTypeEnum, required: true
    argument :firmware_version, String, required: false
    argument :metadata, GraphQL::Types::JSON, required: false

    field :device, Types::RangefinderDeviceObjectType, null: true
    field :newly_registered, Boolean, null: false
    field :errors, [String], null: false

    def resolve(device_id:, name:, device_type:, firmware_version: nil, metadata: nil)
      require_auth!
      require_role!(:manager)

      result = Gps::RegisterDeviceService.call(
        organization: current_organization,
        device_id: device_id,
        name: name,
        device_type: device_type,
        firmware_version: firmware_version,
        metadata: metadata
      )

      if result.success?
        {
          device: result.data[:device],
          newly_registered: result.data[:newly_registered],
          errors: []
        }
      else
        { device: nil, newly_registered: false, errors: result.errors }
      end
    end
  end
end
