module Types
  class SubscriptionType < Types::BaseObject
    field :score_updated, Types::ScoreUpdatePayloadType, null: false do
      description "Triggered when a score is recorded or updated in a tournament"
      argument :tournament_id, ID, required: true
    end

    def score_updated(tournament_id:)
      # Initial value handled by ActionCable broadcast
      object
    end
  end
end
