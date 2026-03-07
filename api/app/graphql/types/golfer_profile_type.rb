module Types
  class GolferProfileType < Types::BaseObject
    field :id, ID, null: false
    field :handicap_index, Float, null: true
    field :home_course, String, null: true
    field :preferred_tee, String, null: true
    field :total_rounds, Integer, null: false
    field :best_score, Integer, null: true
    field :average_score, Float, null: true
    field :last_played_on, GraphQL::Types::ISO8601Date, null: true
    field :handicap_updated_at, GraphQL::Types::ISO8601DateTime, null: true
    field :display_handicap, String, null: false
    field :user, Types::UserType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :rounds, [Types::RoundType], null: false do
      argument :limit, Integer, required: false, default_value: 20
      argument :offset, Integer, required: false, default_value: 0
    end

    field :handicap_revisions, [Types::HandicapRevisionType], null: false do
      argument :months, Integer, required: false, default_value: 12
    end

    field :recent_rounds, [Types::RoundType], null: false

    def rounds(limit:, offset:)
      object.play_history(limit: limit, offset: offset)
    end

    def handicap_revisions(months:)
      object.handicap_trend(months: months)
    end

    def recent_rounds
      object.rounds.recent.limit(5)
    end
  end
end
