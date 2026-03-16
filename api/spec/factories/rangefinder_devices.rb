FactoryBot.define do
  factory :rangefinder_device do
    organization
    device_id { SecureRandom.hex(8) }
    name { "#{Faker::Company.name} GPS Unit" }
    device_type { :cart_gps }
    status { :active }
    firmware_version { "#{rand(1..3)}.#{rand(0..9)}.#{rand(0..9)}" }
    battery_level { rand(20.0..100.0).round(1) }
    last_seen_at { Time.current }
    metadata { {} }

    trait :handheld do
      device_type { :handheld_gps }
      name { "Handheld GPS #{SecureRandom.hex(3).upcase}" }
    end

    trait :watch do
      device_type { :watch_gps }
      name { "GPS Watch #{SecureRandom.hex(3).upcase}" }
    end

    trait :laser do
      device_type { :laser_rangefinder }
      name { "Laser Rangefinder #{SecureRandom.hex(3).upcase}" }
    end

    trait :offline do
      last_seen_at { 1.hour.ago }
    end

    trait :inactive do
      status { :inactive }
    end

    trait :low_battery do
      battery_level { rand(1.0..10.0).round(1) }
    end
  end
end
