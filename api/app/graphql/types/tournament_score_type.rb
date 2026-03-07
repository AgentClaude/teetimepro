module Types
  class TournamentScoreType < Types::BaseObject
    field :id, ID, null: false
    field :hole_number, Integer, null: false
    field :strokes, Integer, null: false
    field :par, Integer, null: false
    field :putts, Integer, null: true
    field :fairway_hit, Boolean, null: true
    field :green_in_regulation, Boolean, null: true
    field :score_to_par, Integer, null: false
    field :score_label, String, null: false

    field :tournament_round, Types::TournamentRoundType, null: false
    field :tournament_entry, Types::TournamentEntryType, null: false

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
