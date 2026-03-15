module Mutations
  class AbandonScorecard < BaseMutation
    description "Abandon an in-progress scorecard"

    argument :scorecard_id, ID, required: true

    field :scorecard, Types::ScorecardType, null: true
    field :errors, [String], null: false

    def resolve(scorecard_id:)
      scorecard = Scorecard.find(scorecard_id)

      result = Scorecards::AbandonScorecardService.call(scorecard: scorecard)

      if result.success?
        { scorecard: result.scorecard, errors: [] }
      else
        { scorecard: nil, errors: result.errors }
      end
    end
  end
end
