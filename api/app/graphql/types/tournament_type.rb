module Types
  class TournamentType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: true
    field :format, Types::TournamentFormatEnum, null: false
    field :status, Types::TournamentStatusEnum, null: false
    field :course, Types::CourseType, null: false
    field :created_by, Types::UserType, null: false

    field :start_date, GraphQL::Types::ISO8601Date, null: false
    field :end_date, GraphQL::Types::ISO8601Date, null: false
    field :holes, Integer, null: false
    field :team_size, Integer, null: false

    field :max_participants, Integer, null: true
    field :min_participants, Integer, null: false
    field :entries_count, Integer, null: false
    field :registration_available, Boolean, null: false

    field :entry_fee_cents, Integer, null: false
    field :entry_fee_currency, String, null: false
    field :entry_fee_display, String, null: false

    field :handicap_enabled, Boolean, null: false
    field :max_handicap, Float, null: true
    field :rules, GraphQL::Types::JSON, null: false
    field :prize_structure, GraphQL::Types::JSON, null: false

    field :registration_opens_at, GraphQL::Types::ISO8601DateTime, null: true
    field :registration_closes_at, GraphQL::Types::ISO8601DateTime, null: true

    field :tournament_entries, [Types::TournamentEntryType], null: false
    field :tournament_rounds, [Types::TournamentRoundType], null: false
    field :tournament_prizes, [Types::TournamentPrizeType], null: false
    field :tournament_results, [Types::TournamentResultType], null: false
    field :days, Integer, null: false

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def entry_fee_display
      Money.new(object.entry_fee_cents, object.entry_fee_currency).format
    end

    def registration_available
      object.registration_available?
    end

    def tournament_entries
      object.tournament_entries.active.includes(:user)
    end

    def tournament_rounds
      object.tournament_rounds.chronological
    end

    def tournament_prizes
      object.tournament_prizes.by_position
    end

    def tournament_results
      object.tournament_results.by_position
    end
  end
end
