module Gps
  class RegisterDeviceService < ApplicationService
    attr_accessor :organization, :device_id, :name, :device_type,
                  :firmware_version, :metadata

    validates :organization, :device_id, :name, :device_type, presence: true

    def call
      return validation_failure(self) unless valid?

      device = RangefinderDevice.find_or_initialize_by(
        organization: organization,
        device_id: device_id
      )

      device.assign_attributes(
        name: name,
        device_type: device_type,
        firmware_version: firmware_version,
        metadata: metadata || {},
        status: :active,
        last_seen_at: Time.current
      )

      if device.save
        success(device: device, newly_registered: device.previously_new_record?)
      else
        failure(device.errors.full_messages)
      end
    end
  end
end
