module Tournaments
  class FinalizeResultsService < ApplicationService
    attr_accessor :tournament

    validates :tournament, presence: true
    validate :tournament_ready_for_finalization

    def call
      return validation_failure(self) unless valid?

      # Get leaderboard from existing service
      leaderboard_result = Leaderboard::CalculateService.call(tournament: tournament)
      return failure(["Failed to calculate leaderboard: #{leaderboard_result.error_messages}"]) unless leaderboard_result.success?

      results = nil
      awarded_prizes = []

      ApplicationRecord.transaction do
        # Clear existing results
        tournament.tournament_results.destroy_all

        # Create tournament results from leaderboard
        results = create_results_from_leaderboard(leaderboard_result.data[:entries])

        # Award prizes
        awarded_prizes = award_prizes(results)

        # Update tournament status if needed
        tournament.update!(status: :completed) if tournament.in_progress?

        # Finalize all results
        results.each { |result| result.update!(finalized_at: Time.current) }
      end

      success(results: results, awarded_prizes: awarded_prizes)
    end

    private

    def tournament_ready_for_finalization
      return unless tournament

      unless tournament.completed? || tournament.in_progress?
        errors.add(:tournament, "must be completed or in progress to finalize results")
        return
      end

      # Check if all rounds are completed (for in_progress tournaments)
      if tournament.in_progress?
        incomplete_rounds = tournament.tournament_rounds.where.not(status: :completed)
        if incomplete_rounds.exists?
          errors.add(:tournament, "cannot finalize results with incomplete rounds")
        end
      end

      # Ensure there are entries
      if tournament.tournament_entries.active.empty?
        errors.add(:tournament, "cannot finalize results with no active entries")
      end
    end

    def create_results_from_leaderboard(leaderboard_entries)
      results = []

      leaderboard_entries.each do |entry_data|
        tournament_entry = tournament.tournament_entries.find(entry_data[:entry_id])
        
        result = tournament.tournament_results.create!(
          tournament_entry: tournament_entry,
          position: entry_data[:position],
          total_strokes: entry_data[:total_strokes],
          total_to_par: entry_data[:total_to_par],
          tied: entry_data[:tied]
        )
        
        results << result
      end

      results.sort_by(&:position)
    end

    def award_prizes(results)
      awarded_prizes = []
      
      # Get all available prizes ordered by position
      available_prizes = tournament.tournament_prizes.by_position
      
      # Group results by position to handle ties
      results_by_position = results.group_by(&:position)
      
      available_prizes.each do |prize|
        # Find results for this position
        position_results = results_by_position[prize.position]
        next unless position_results&.any?

        # For ties, award to first result (could be enhanced for tie-breaking rules)
        winner_result = position_results.first
        
        # Award the prize
        prize.update!(awarded_to: winner_result.tournament_entry)
        winner_result.update!(prize_awarded: true)
        
        awarded_prizes << {
          prize: prize,
          winner: winner_result
        }
      end

      awarded_prizes
    end
  end
end