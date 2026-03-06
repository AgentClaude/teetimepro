module Mutations
  class CreateCourse < BaseMutation
    argument :name, String, required: true
    argument :holes, Integer, required: true
    argument :interval_minutes, Integer, required: true
    argument :max_players_per_slot, Integer, required: false
    argument :first_tee_time, String, required: true
    argument :last_tee_time, String, required: true
    argument :weekday_rate_cents, Integer, required: false
    argument :weekend_rate_cents, Integer, required: false
    argument :twilight_rate_cents, Integer, required: false
    argument :address, String, required: false
    argument :phone, String, required: false

    field :course, Types::CourseType, null: true
    field :errors, [String], null: false

    def resolve(**args)
      org = require_auth!
      require_role!(:manager)

      course = org.courses.new(
        name: args[:name],
        holes: args[:holes],
        interval_minutes: args[:interval_minutes],
        max_players_per_slot: args[:max_players_per_slot] || 4,
        first_tee_time: Time.zone.parse(args[:first_tee_time]),
        last_tee_time: Time.zone.parse(args[:last_tee_time]),
        weekday_rate_cents: args[:weekday_rate_cents],
        weekend_rate_cents: args[:weekend_rate_cents],
        twilight_rate_cents: args[:twilight_rate_cents],
        address: args[:address],
        phone: args[:phone]
      )

      if course.save
        { course: course, errors: [] }
      else
        { course: nil, errors: course.errors.full_messages }
      end
    end
  end
end
