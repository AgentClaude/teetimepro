module Mutations
  class FinalizeTournamentResults < BaseMutation
    description "Finalize tournament results and award prizes"

    argument :tournament_id, ID, required: true

    field :results, [Types::TournamentResultType], null: true
    field :awarded_prizes, [Types::TournamentPrizeType], null: true
    field :errors, [String], null: false

    def resolve(tournament_id:)
      org = require_auth!
      require_role!(:staff)

      tournament = org.tournaments.find(tournament_id)

      result = Tournaments::FinalizeResultsService.call(tournament: tournament)

      if result.success?
        awarded_prizes = result.data[:awarded_prizes].map { |ap| ap[:prize] }
        
        { 
          results: result.data[:results], 
          awarded_prizes: awarded_prizes,
          errors: [] 
        }
      else
        { results: nil, awarded_prizes: nil, errors: result.errors }
      end
    end
  end
end