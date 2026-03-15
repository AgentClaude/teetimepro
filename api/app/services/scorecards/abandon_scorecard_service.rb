module Scorecards
  class AbandonScorecardService < ApplicationService
    attr_accessor :scorecard

    validates :scorecard, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Scorecard is not in progress"]) unless scorecard.in_progress?

      scorecard.update!(status: "abandoned")

      success(scorecard: scorecard.reload)
    end
  end
end
