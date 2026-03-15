module Scorecards
  class UpdateHoleScoreService < ApplicationService
    attr_accessor :scorecard, :hole_number, :strokes, :putts,
                  :fairway_hit, :green_in_regulation, :penalties, :notes

    validates :scorecard, presence: true
    validates :hole_number, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Scorecard is not in progress"]) unless scorecard.in_progress?

      hole_score = scorecard.hole_scores.find_by(hole_number: hole_number)
      return failure(["Hole #{hole_number} not found on this scorecard"]) unless hole_score

      attrs = {}
      attrs[:strokes] = strokes if strokes.present?
      attrs[:putts] = putts unless putts.nil?
      attrs[:fairway_hit] = fairway_hit unless fairway_hit.nil?
      attrs[:green_in_regulation] = green_in_regulation unless green_in_regulation.nil?
      attrs[:penalties] = penalties unless penalties.nil?
      attrs[:notes] = notes unless notes.nil?

      if hole_score.update(attrs)
        scorecard.recalculate_totals!
        success(hole_score: hole_score.reload, scorecard: scorecard.reload)
      else
        validation_failure(hole_score)
      end
    end
  end
end
