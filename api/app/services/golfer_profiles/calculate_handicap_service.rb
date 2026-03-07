module GolferProfiles
  # Simplified WHS (World Handicap System) handicap calculation
  # Uses best differentials from last 20 rounds
  class CalculateHandicapService < ApplicationService
    attr_accessor :golfer_profile, :source

    # Number of best differentials to use based on rounds available
    DIFFERENTIAL_TABLE = {
      3 => 1, 4 => 1, 5 => 1, 6 => 2,
      7 => 2, 8 => 2, 9 => 3, 10 => 3,
      11 => 3, 12 => 4, 13 => 4, 14 => 4,
      15 => 5, 16 => 5, 17 => 6, 18 => 6,
      19 => 7, 20 => 8
    }.freeze

    validates :golfer_profile, presence: true

    def call
      return validation_failure(self) unless valid?

      eligible_rounds = golfer_profile.handicap_eligible_rounds
      round_count = eligible_rounds.count

      if round_count < 3
        return failure("Need at least 3 rounds with course rating and slope to calculate handicap")
      end

      differentials = eligible_rounds.map(&:differential).compact.sort
      count_to_use = DIFFERENTIAL_TABLE[[round_count, 20].min]
      best_differentials = differentials.first(count_to_use)

      new_index = (best_differentials.sum / count_to_use.to_f).round(1)
      # Cap at 54.0 per WHS rules
      new_index = [new_index, 54.0].min

      previous_index = golfer_profile.handicap_index

      ActiveRecord::Base.transaction do
        golfer_profile.update!(
          handicap_index: new_index,
          handicap_updated_at: Time.current
        )

        golfer_profile.handicap_revisions.create!(
          handicap_index: new_index,
          previous_index: previous_index,
          rounds_used: count_to_use,
          effective_date: Date.current,
          source: source || "calculated",
          notes: "Calculated from #{count_to_use} best of #{round_count} eligible rounds"
        )
      end

      success(
        golfer_profile: golfer_profile.reload,
        handicap_index: new_index,
        previous_index: previous_index,
        rounds_used: count_to_use
      )
    end
  end
end
