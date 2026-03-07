module Mutations
  class RecordRound < BaseMutation
    description "Record a round of golf for a golfer profile"

    argument :golfer_profile_id, ID, required: true
    argument :course_name, String, required: true
    argument :played_on, GraphQL::Types::ISO8601Date, required: true
    argument :score, Integer, required: true
    argument :holes_played, Integer, required: false, default_value: 18
    argument :course_rating, Float, required: false
    argument :slope_rating, Integer, required: false
    argument :course_id, ID, required: false
    argument :tee_color, String, required: false
    argument :notes, String, required: false
    argument :putts, Integer, required: false
    argument :fairways_hit, Integer, required: false
    argument :greens_in_regulation, Integer, required: false

    field :round, Types::RoundType, null: true
    field :golfer_profile, Types::GolferProfileType, null: true
    field :errors, [String], null: false

    def resolve(**args)
      golfer_profile = GolferProfile.find(args.delete(:golfer_profile_id))
      result = GolferProfiles::RecordRoundService.call(
        golfer_profile: golfer_profile,
        **args
      )

      if result.success?
        { round: result.round, golfer_profile: result.golfer_profile, errors: [] }
      else
        { round: nil, golfer_profile: nil, errors: result.errors }
      end
    end
  end
end
