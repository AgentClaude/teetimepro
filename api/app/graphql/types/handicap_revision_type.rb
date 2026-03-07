module Types
  class HandicapRevisionType < Types::BaseObject
    field :id, ID, null: false
    field :handicap_index, Float, null: false
    field :previous_index, Float, null: true
    field :rounds_used, Integer, null: false
    field :effective_date, GraphQL::Types::ISO8601Date, null: false
    field :source, String, null: false
    field :notes, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :change, Float, null: true

    def change
      return nil unless object.previous_index

      (object.handicap_index - object.previous_index).round(1)
    end
  end
end
