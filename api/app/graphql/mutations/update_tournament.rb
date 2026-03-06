module Mutations
  class UpdateTournament < BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: false
    argument :description, String, required: false
    argument :format, Types::TournamentFormatEnum, required: false
    argument :status, Types::TournamentStatusEnum, required: false
    argument :start_date, GraphQL::Types::ISO8601Date, required: false
    argument :end_date, GraphQL::Types::ISO8601Date, required: false
    argument :max_participants, Integer, required: false
    argument :min_participants, Integer, required: false
    argument :team_size, Integer, required: false
    argument :entry_fee_cents, Integer, required: false
    argument :holes, Integer, required: false
    argument :handicap_enabled, Boolean, required: false
    argument :max_handicap, Float, required: false
    argument :rules, GraphQL::Types::JSON, required: false
    argument :prize_structure, GraphQL::Types::JSON, required: false
    argument :registration_opens_at, GraphQL::Types::ISO8601DateTime, required: false
    argument :registration_closes_at, GraphQL::Types::ISO8601DateTime, required: false

    field :tournament, Types::TournamentType, null: true
    field :errors, [String], null: false

    def resolve(id:, **attributes)
      org = require_auth!
      require_role!(:manager)

      tournament = Tournament.where(organization: org).find(id)

      result = Tournaments::UpdateTournamentService.call(
        tournament: tournament,
        user: current_user,
        attributes: attributes.compact
      )

      if result.success?
        { tournament: result.data.tournament, errors: [] }
      else
        { tournament: nil, errors: result.errors }
      end
    end
  end
end
