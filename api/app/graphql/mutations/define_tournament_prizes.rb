module Mutations
  class DefineTournamentPrizes < BaseMutation
    description "Define or update prizes for a tournament"

    argument :tournament_id, ID, required: true
    argument :prizes, [Types::TournamentPrizeInputType], required: true

    field :prizes, [Types::TournamentPrizeType], null: true
    field :errors, [String], null: false

    def resolve(tournament_id:, prizes:)
      org = require_auth!
      require_role!(:staff)

      tournament = org.tournaments.find(tournament_id)

      # Convert GraphQL input to hash format expected by service
      prize_definitions = prizes.map do |prize|
        {
          position: prize.position,
          prize_type: prize.prize_type,
          description: prize.description,
          amount_cents: prize.amount_cents || 0
        }
      end

      result = Tournaments::DefinePrizesService.call(
        tournament: tournament,
        prize_definitions: prize_definitions
      )

      if result.success?
        { prizes: result.data[:prizes], errors: [] }
      else
        { prizes: nil, errors: result.errors }
      end
    end
  end
end