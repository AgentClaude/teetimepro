module Mutations
  class FinalizeScorecard < BaseMutation
    description "Finalize a scorecard and record the round"

    argument :scorecard_id, ID, required: true

    field :scorecard, Types::ScorecardType, null: true
    field :round, Types::RoundType, null: true
    field :errors, [String], null: false

    def resolve(scorecard_id:)
      scorecard = Scorecard.find(scorecard_id)

      result = Scorecards::FinalizeScorecardService.call(scorecard: scorecard)

      if result.success?
        { scorecard: result.scorecard, round: result.round, errors: [] }
      else
        { scorecard: nil, round: nil, errors: result.errors }
      end
    end
  end
end
