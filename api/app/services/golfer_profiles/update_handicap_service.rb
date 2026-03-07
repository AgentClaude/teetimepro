module GolferProfiles
  # Manually set a handicap (e.g., imported from external system)
  class UpdateHandicapService < ApplicationService
    attr_accessor :golfer_profile, :handicap_index, :source, :notes

    validates :golfer_profile, presence: true
    validates :handicap_index, presence: true, numericality: { in: -10.0..54.0 }

    def call
      return validation_failure(self) unless valid?

      previous_index = golfer_profile.handicap_index

      ActiveRecord::Base.transaction do
        golfer_profile.update!(
          handicap_index: handicap_index,
          handicap_updated_at: Time.current
        )

        golfer_profile.handicap_revisions.create!(
          handicap_index: handicap_index,
          previous_index: previous_index,
          rounds_used: 0,
          effective_date: Date.current,
          source: source || "manual",
          notes: notes || "Manually updated"
        )
      end

      success(
        golfer_profile: golfer_profile.reload,
        handicap_index: handicap_index,
        previous_index: previous_index
      )
    end
  end
end
