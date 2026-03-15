module Scorecards
  class FinalizeScorecardService < ApplicationService
    attr_accessor :scorecard

    validates :scorecard, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Scorecard is not in progress"]) unless scorecard.in_progress?

      scored_holes = scorecard.hole_scores.where.not(strokes: nil)
      return failure(["No holes have been scored yet"]) if scored_holes.empty?

      ActiveRecord::Base.transaction do
        scorecard.recalculate_totals!

        scorecard.update!(
          status: "completed",
          completed_at: Time.current
        )

        # Create a Round record for handicap tracking
        round = create_round_from_scorecard

        scorecard.update!(round: round) if round

        success(scorecard: scorecard.reload, round: round)
      end
    end

    private

    def create_round_from_scorecard
      return nil unless scorecard.total_strokes

      GolferProfiles::RecordRoundService.call(
        golfer_profile: scorecard.golfer_profile,
        course_id: scorecard.course_id,
        course_name: scorecard.course.name,
        played_on: scorecard.played_on,
        score: scorecard.total_strokes,
        holes_played: scorecard.holes_played,
        course_rating: scorecard.course_rating,
        slope_rating: scorecard.slope_rating,
        tee_color: scorecard.tee_color,
        putts: scorecard.total_putts,
        fairways_hit: scorecard.total_fairways_hit,
        greens_in_regulation: scorecard.total_greens_in_regulation,
        notes: scorecard.notes
      ).then { |result| result.success? ? result.round : nil }
    end
  end
end
