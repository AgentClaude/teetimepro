module Mutations
  class CreateScorecard < BaseMutation
    description "Start a new digital scorecard"

    argument :golfer_profile_id, ID, required: true
    argument :course_id, ID, required: true
    argument :played_on, GraphQL::Types::ISO8601Date, required: true
    argument :holes_played, Integer, required: false, default_value: 18
    argument :tee_color, String, required: false
    argument :course_rating, Float, required: false
    argument :slope_rating, Integer, required: false
    argument :booking_id, ID, required: false
    argument :notes, String, required: false

    field :scorecard, Types::ScorecardType, null: true
    field :errors, [String], null: false

    def resolve(**args)
      golfer_profile = GolferProfile.find(args.delete(:golfer_profile_id))
      course = Course.find(args.delete(:course_id))

      result = Scorecards::CreateScorecardService.call(
        golfer_profile: golfer_profile,
        course: course,
        **args
      )

      if result.success?
        { scorecard: result.scorecard, errors: [] }
      else
        { scorecard: nil, errors: result.errors }
      end
    end
  end
end
