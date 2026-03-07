module Types
  class AvailabilityFiltersType < Types::BaseObject
    field :players, Integer, null: false
    field :time_preference, String, null: true
    field :course_id, ID, null: true
  end
end
