module Types
  class TournamentEntryType < Types::BaseObject
    field :id, ID, null: false
    field :tournament, Types::TournamentType, null: false
    field :user, Types::UserType, null: false
    field :status, Types::TournamentEntryStatusEnum, null: false
    field :team_name, String, null: true
    field :handicap_index, Float, null: true
    field :starting_hole, Integer, null: true
    field :tee_time, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
