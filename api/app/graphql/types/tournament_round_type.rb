module Types
  class TournamentRoundType < Types::BaseObject
    field :id, ID, null: false
    field :round_number, Integer, null: false
    field :play_date, GraphQL::Types::ISO8601Date, null: false
    field :status, Types::TournamentRoundStatusEnum, null: false
    field :tournament, Types::TournamentType, null: false
    field :scores_count, Integer, null: false

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def scores_count
      object.tournament_scores.count
    end
  end
end
