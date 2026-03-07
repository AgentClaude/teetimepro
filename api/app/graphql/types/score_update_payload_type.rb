module Types
  class ScoreUpdatePayloadType < Types::BaseObject
    field :tournament_id, ID, null: false
    field :score, Types::TournamentScoreType, null: false
    field :leaderboard, Types::LeaderboardType, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
