module Types
  class TournamentPrizeType < Types::BaseObject
    field :id, ID, null: false
    field :tournament_id, ID, null: false
    field :position, Integer, null: false
    field :prize_type, String, null: false
    field :description, String, null: false
    field :amount_cents, Integer, null: false
    field :amount_display, String, null: false
    field :awarded, Boolean, null: false
    field :awarded_to, Types::TournamentEntryType, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def amount_display
      object.amount.format
    end

    def awarded
      object.awarded?
    end

    def prize_type
      object.prize_type.humanize
    end
  end
end