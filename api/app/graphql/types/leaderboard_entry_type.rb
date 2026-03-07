module Types
  class LeaderboardEntryType < Types::BaseObject
    field :position, Integer, null: false
    field :tied, Boolean, null: false
    field :entry_id, ID, null: false
    field :player_id, ID, null: false
    field :player_name, String, null: false
    field :team_name, String, null: true
    field :handicap_index, Float, null: true
    field :total_strokes, Integer, null: false
    field :total_to_par, Integer, null: false
    field :total_holes_played, Integer, null: false
    field :thru, String, null: true
    field :rounds, [Types::LeaderboardRoundType], null: false
  end
end
