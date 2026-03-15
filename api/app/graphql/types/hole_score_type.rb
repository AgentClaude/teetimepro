module Types
  class HoleScoreType < BaseObject
    description "Score for a single hole on a scorecard"

    field :id, ID, null: false
    field :hole_number, Integer, null: false
    field :par, Integer, null: false
    field :strokes, Integer, null: true
    field :putts, Integer, null: true
    field :fairway_hit, Boolean, null: true
    field :green_in_regulation, Boolean, null: true
    field :penalties, Integer, null: true
    field :score_to_par, Integer, null: true
    field :notes, String, null: true
  end
end
