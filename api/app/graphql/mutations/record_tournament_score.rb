module Mutations
  class RecordTournamentScore < BaseMutation
    description "Record or update a score for a hole in a tournament round"

    argument :tournament_id, ID, required: true
    argument :tournament_entry_id, ID, required: true
    argument :round_id, ID, required: true
    argument :hole_number, Integer, required: true
    argument :strokes, Integer, required: true
    argument :par, Integer, required: true
    argument :putts, Integer, required: false
    argument :fairway_hit, Boolean, required: false
    argument :green_in_regulation, Boolean, required: false

    field :score, Types::TournamentScoreType, null: true
    field :errors, [String], null: false

    def resolve(tournament_id:, tournament_entry_id:, round_id:, **attrs)
      org = require_auth!
      require_role!(:staff)

      tournament = org.tournaments.find(tournament_id)
      entry = tournament.tournament_entries.find(tournament_entry_id)
      round = tournament.tournament_rounds.find(round_id)

      result = Tournaments::RecordScoreService.call(
        tournament: tournament,
        tournament_entry: entry,
        tournament_round: round,
        current_user: current_user,
        **attrs
      )

      if result.success?
        { score: result.data[:score], errors: [] }
      else
        { score: nil, errors: result.errors }
      end
    end
  end
end
