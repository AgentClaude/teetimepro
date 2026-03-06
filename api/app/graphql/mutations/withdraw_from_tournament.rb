module Mutations
  class WithdrawFromTournament < BaseMutation
    argument :tournament_id, ID, required: true

    field :tournament_entry, Types::TournamentEntryType, null: true
    field :errors, [String], null: false

    def resolve(tournament_id:)
      org = require_auth!

      tournament = Tournament.where(organization: org).find(tournament_id)

      result = Tournaments::WithdrawParticipantService.call(
        tournament: tournament,
        user: current_user
      )

      if result.success?
        { tournament_entry: result.data.entry, errors: [] }
      else
        { tournament_entry: nil, errors: result.errors }
      end
    end
  end
end
