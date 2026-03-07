module GolferProfiles
  class RecordRoundService < ApplicationService
    attr_accessor :golfer_profile, :course_name, :played_on, :score,
                  :holes_played, :course_rating, :slope_rating,
                  :tee_color, :notes, :putts, :fairways_hit,
                  :greens_in_regulation, :course_id

    validates :golfer_profile, presence: true
    validates :course_name, presence: true
    validates :played_on, presence: true
    validates :score, presence: true

    def call
      return validation_failure(self) unless valid?

      round = golfer_profile.rounds.build(
        course_id: course_id,
        course_name: course_name,
        played_on: played_on,
        score: score,
        holes_played: holes_played || 18,
        course_rating: course_rating,
        slope_rating: slope_rating,
        tee_color: tee_color,
        notes: notes,
        putts: putts,
        fairways_hit: fairways_hit,
        greens_in_regulation: greens_in_regulation
      )

      if round.save
        # Recalculate handicap if we have enough eligible rounds
        recalculate_handicap_if_eligible

        success(round: round, golfer_profile: golfer_profile.reload)
      else
        validation_failure(round)
      end
    end

    private

    def recalculate_handicap_if_eligible
      eligible_rounds = golfer_profile.handicap_eligible_rounds
      return if eligible_rounds.count < 3

      CalculateHandicapService.call(golfer_profile: golfer_profile)
    end
  end
end
