module Mutations
  class UpdateHoleScore < BaseMutation
    description "Update the score for a single hole"

    argument :scorecard_id, ID, required: true
    argument :hole_number, Integer, required: true
    argument :strokes, Integer, required: false
    argument :putts, Integer, required: false
    argument :fairway_hit, Boolean, required: false
    argument :green_in_regulation, Boolean, required: false
    argument :penalties, Integer, required: false
    argument :notes, String, required: false

    field :hole_score, Types::HoleScoreType, null: true
    field :scorecard, Types::ScorecardType, null: true
    field :errors, [String], null: false

    def resolve(**args)
      scorecard = Scorecard.find(args.delete(:scorecard_id))

      result = Scorecards::UpdateHoleScoreService.call(
        scorecard: scorecard,
        **args
      )

      if result.success?
        { hole_score: result.hole_score, scorecard: result.scorecard, errors: [] }
      else
        { hole_score: nil, scorecard: nil, errors: result.errors }
      end
    end
  end
end
