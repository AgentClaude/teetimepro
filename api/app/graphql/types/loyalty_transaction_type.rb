module Types
  class LoyaltyTransactionType < Types::BaseObject
    field :id, ID, null: false
    field :transaction_type, String, null: false
    field :points, Integer, null: false
    field :points_display, String, null: false
    field :description, String, null: false
    field :balance_after, Integer, null: false
    field :transaction_icon, String, null: false
    field :positive, Boolean, null: false
    field :negative, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :loyalty_account, Types::LoyaltyAccountType, null: false
    field :source_type, String, null: true
    field :source_id, ID, null: true

    def points_display
      object.points_display
    end

    def transaction_icon
      object.transaction_icon
    end

    def positive
      object.positive?
    end

    def negative
      object.negative?
    end

    def source_type
      object.source_type
    end

    def source_id
      object.source_id
    end
  end
end