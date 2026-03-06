module Mutations
  class CreateTournament < BaseMutation
    argument :course_id, ID, required: true
    argument :name, String, required: true
    argument :description, String, required: false
    argument :format, Types::TournamentFormatEnum, required: true
    argument :start_date, GraphQL::Types::ISO8601Date, required: true
    argument :end_date, GraphQL::Types::ISO8601Date, required: true
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

    def resolve(course_id:, **args)
      org = require_auth!
      require_role!(:manager)

      course = Course.where(organization: org).find(course_id)

      result = Tournaments::CreateTournamentService.call(
        organization: org,
        course: course,
        user: current_user,
        **args
      )

      if result.success?
        { tournament: result.data.tournament, errors: [] }
      else
        { tournament: nil, errors: result.errors }
      end
    end
  end
end
