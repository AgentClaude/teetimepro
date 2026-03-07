module Types
  class PricingRuleTypeEnum < Types::BaseEnum
    description "Types of pricing rules"

    value "TIME_OF_DAY", "Price adjustment based on time of day", value: "time_of_day"
    value "DAY_OF_WEEK", "Price adjustment based on day of the week", value: "day_of_week"
    value "OCCUPANCY", "Price adjustment based on course occupancy rate", value: "occupancy"
    value "WEATHER", "Price adjustment based on weather conditions", value: "weather"
    value "ADVANCE_BOOKING", "Price adjustment based on advance booking time", value: "advance_booking"
    value "LAST_MINUTE", "Price adjustment for last-minute bookings", value: "last_minute"
  end
end