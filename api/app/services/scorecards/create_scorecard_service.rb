module Scorecards
  class CreateScorecardService < ApplicationService
    attr_accessor :golfer_profile, :course, :played_on, :holes_played,
                  :tee_color, :course_rating, :slope_rating, :booking_id, :notes

    validates :golfer_profile, presence: true
    validates :course, presence: true
    validates :played_on, presence: true

    def call
      return validation_failure(self) unless valid?

      ActiveRecord::Base.transaction do
        scorecard = golfer_profile.scorecards.build(
          course: course,
          booking_id: booking_id,
          played_on: played_on,
          holes_played: holes_played || 18,
          tee_color: tee_color,
          course_rating: course_rating,
          slope_rating: slope_rating,
          notes: notes,
          status: "in_progress",
          started_at: Time.current
        )

        unless scorecard.save
          return validation_failure(scorecard)
        end

        # Pre-populate hole scores from course hole configuration
        create_hole_scores(scorecard)

        success(scorecard: scorecard.reload)
      end
    end

    private

    def create_hole_scores(scorecard)
      course_holes = course.course_holes.ordered.limit(scorecard.holes_played)

      if course_holes.any?
        course_holes.each do |course_hole|
          scorecard.hole_scores.create!(
            hole_number: course_hole.hole_number,
            par: course_hole.par
          )
        end
      else
        # Default pars if course holes not configured
        default_pars = default_par_layout(scorecard.holes_played)
        default_pars.each_with_index do |par, index|
          scorecard.hole_scores.create!(
            hole_number: index + 1,
            par: par
          )
        end
      end
    end

    def default_par_layout(holes)
      # Standard par 72 layout (4-4-3-4-5-4-3-4-5 repeated)
      nine_holes = [4, 4, 3, 4, 5, 4, 3, 4, 5]
      holes == 18 ? nine_holes * 2 : nine_holes
    end
  end
end
