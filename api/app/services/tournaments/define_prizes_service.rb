module Tournaments
  class DefinePrizesService < ApplicationService
    attr_accessor :tournament, :prize_definitions

    validates :tournament, presence: true
    validates :prize_definitions, presence: true
    validate :tournament_not_completed_or_cancelled
    validate :prize_definitions_valid

    def call
      return validation_failure(self) unless valid?

      prizes = nil
      ApplicationRecord.transaction do
        # Remove existing prizes for clean slate
        tournament.tournament_prizes.destroy_all

        # Create new prizes
        prizes = prize_definitions.map do |prize_def|
          tournament.tournament_prizes.create!(
            position: prize_def[:position],
            prize_type: prize_def[:prize_type],
            description: prize_def[:description],
            amount_cents: prize_def[:amount_cents] || 0
          )
        end
      end

      success(prizes: prizes)
    end

    private

    def tournament_not_completed_or_cancelled
      return unless tournament

      if tournament.completed? || tournament.cancelled?
        errors.add(:tournament, "cannot have prizes modified when completed or cancelled")
      end
    end

    def prize_definitions_valid
      return unless prize_definitions.is_a?(Array)

      prize_definitions.each_with_index do |prize_def, index|
        unless prize_def.is_a?(Hash)
          errors.add(:prize_definitions, "must be an array of hashes")
          next
        end

        # Validate required fields
        unless prize_def[:position].present? && prize_def[:position].is_a?(Integer) && prize_def[:position] > 0
          errors.add(:prize_definitions, "position must be a positive integer at index #{index}")
        end

        unless prize_def[:prize_type].present? && TournamentPrize.prize_types.key?(prize_def[:prize_type].to_s)
          errors.add(:prize_definitions, "prize_type must be valid at index #{index}")
        end

        unless prize_def[:description].present?
          errors.add(:prize_definitions, "description is required at index #{index}")
        end

        # Validate amount_cents if present
        if prize_def[:amount_cents].present? && (!prize_def[:amount_cents].is_a?(Integer) || prize_def[:amount_cents] < 0)
          errors.add(:prize_definitions, "amount_cents must be a non-negative integer at index #{index}")
        end
      end

      # Check for duplicate positions
      positions = prize_definitions.map { |p| p[:position] }.compact
      if positions.uniq.length != positions.length
        errors.add(:prize_definitions, "cannot have duplicate positions")
      end
    end
  end
end