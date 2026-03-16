module Types
  class RangefinderDeviceTypeEnum < BaseEnum
    description "Type of rangefinder/GPS device"

    value "HANDHELD_GPS", "Handheld GPS unit", value: "handheld_gps"
    value "CART_GPS", "Golf cart mounted GPS", value: "cart_gps"
    value "WATCH_GPS", "GPS watch", value: "watch_gps"
    value "LASER_RANGEFINDER", "Laser rangefinder", value: "laser_rangefinder"
    value "BLUETOOTH_BEACON", "Bluetooth beacon", value: "bluetooth_beacon"
  end
end
