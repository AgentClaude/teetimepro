module Mutations
  class RegisterForTournament < BaseMutation
    argument :tournament_id, ID, required: true
    argument :handicap_index, Float, required: false
    argument :team_name, String, required: false
    argument :payment_method_id, String, required: false

    field :tournament_entry, Types::TournamentEntryType, null: true
    field :errors, [String], null: false

    def resolve(tournament_id:, handicap_index: nil, team_name: nil, payment_method_id: nil)
      org = require_auth!

      tournament = Tournament.where(organization: org).find(tournament_id)

      result = Tournaments::RegisterParticipantService.call(
        tournament: tournament,
        user: current_user,
        handicap_index: handicap_index,
        team_name: team_name,
        payment_method_id: payment_method_id
      )

      if result.success?
        { tournament_entry: result.data.entry, errors: [] }
      else
        { tournament_entry: nil, errors: result.errors }
      end
    end
  end
end
