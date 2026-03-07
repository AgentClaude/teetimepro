module Tournaments
  class RecordScoreService < ApplicationService
    attr_accessor :tournament, :tournament_entry, :tournament_round,
                  :hole_number, :strokes, :par, :putts, :fairway_hit,
                  :green_in_regulation, :current_user

    validates :tournament, :tournament_entry, :tournament_round, presence: true
    validates :hole_number, :strokes, :par, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Tournament is not in progress"]) unless tournament.in_progress?
      return failure(["Round is completed"]) if tournament_round.completed?
      return failure(["Entry does not belong to this tournament"]) unless entry_belongs_to_tournament?

      score = find_or_initialize_score
      score.assign_attributes(score_attributes)

      if score.save
        tournament_round.update!(status: :in_progress) if tournament_round.not_started?
        broadcast_leaderboard_update
        success(score: score)
      else
        validation_failure(score)
      end
    end

    private

    def entry_belongs_to_tournament?
      tournament_entry.tournament_id == tournament.id
    end

    def find_or_initialize_score
      TournamentScore.find_or_initialize_by(
        tournament_round: tournament_round,
        tournament_entry: tournament_entry,
        hole_number: hole_number
      )
    end

    def score_attributes
      {
        strokes: strokes,
        par: par,
        putts: putts,
        fairway_hit: fairway_hit,
        green_in_regulation: green_in_regulation
      }
    end

    def broadcast_leaderboard_update
      leaderboard = Leaderboard::CalculateService.call(tournament: tournament)
      return unless leaderboard.success?

      ActionCable.server.broadcast(
        "leaderboard_#{tournament.id}",
        {
          type: "leaderboard_update",
          tournament_id: tournament.id,
          leaderboard: leaderboard.data[:entries],
          updated_at: Time.current.iso8601
        }
      )
    end
  end
end
