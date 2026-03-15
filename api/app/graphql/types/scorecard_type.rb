module Types
  class ScorecardType < BaseObject
    description "A digital scorecard for tracking hole-by-hole scores"

    field :id, ID, null: false
    field :golfer_profile, Types::GolferProfileType, null: false
    field :course, Types::CourseType, null: false
    field :booking_id, ID, null: true
    field :round, Types::RoundType, null: true
    field :played_on, GraphQL::Types::ISO8601Date, null: false
    field :holes_played, Integer, null: false
    field :total_strokes, Integer, null: true
    field :total_putts, Integer, null: true
    field :total_fairways_hit, Integer, null: true
    field :total_greens_in_regulation, Integer, null: true
    field :total_penalties, Integer, null: true
    field :front_nine_strokes, Integer, null: true
    field :back_nine_strokes, Integer, null: true
    field :score_to_par, Integer, null: true
    field :status, Types::ScorecardStatusEnum, null: false
    field :tee_color, String, null: true
    field :course_rating, Float, null: true
    field :slope_rating, Integer, null: true
    field :notes, String, null: true
    field :started_at, GraphQL::Types::ISO8601DateTime, null: true
    field :completed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :holes_completed, Integer, null: false
    field :hole_scores, [Types::HoleScoreType], null: false

    def hole_scores
      object.hole_scores.order(:hole_number)
    end
  end
end
