module Types
  class TournamentResultType < Types::BaseObject
    field :id, ID, null: false
    field :tournament_id, ID, null: false
    field :tournament_entry, Types::TournamentEntryType, null: false
    field :position, Integer, null: false
    field :position_display, String, null: false
    field :total_strokes, Integer, null: false
    field :total_to_par, Integer, null: false
    field :to_par_display, String, null: false
    field :tied, Boolean, null: false
    field :prize_awarded, Boolean, null: false
    field :finalized, Boolean, null: false
    field :finalized_at, GraphQL::Types::ISO8601DateTime, null: true
    field :player_name, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def position_display
      object.format_position
    end

    def to_par_display
      object.format_to_par
    end

    def finalized
      object.finalized?
    end

    def player_name
      object.player_full_name
    end
  end
end