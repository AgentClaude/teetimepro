module Types
  class LeaderboardRoundType < Types::BaseObject
    field :round_number, Integer, null: false
    field :total_strokes, Integer, null: false
    field :total_par, Integer, null: false
    field :score_to_par, Integer, null: false
    field :holes_played, Integer, null: false
    field :completed, Boolean, null: false
  end
end
