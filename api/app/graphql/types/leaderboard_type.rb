module Types
  class LeaderboardType < Types::BaseObject
    field :tournament_id, ID, null: false
    field :total_rounds, Integer, null: false
    field :current_round, Integer, null: true
    field :entries, [Types::LeaderboardEntryType], null: false
  end
end
