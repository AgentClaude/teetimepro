class CourseHole < ApplicationRecord
  belongs_to :course

  validates :hole_number, presence: true, inclusion: { in: 1..36 },
            uniqueness: { scope: :course_id, message: "already configured for this course" }
  validates :par, presence: true, inclusion: { in: 3..6 }
  validates :yardage, numericality: { in: 50..700 }, allow_nil: true
  validates :handicap_index, numericality: { in: 1..18 }, allow_nil: true

  scope :ordered, -> { order(:hole_number) }
  scope :front_nine, -> { where(hole_number: 1..9) }
  scope :back_nine, -> { where(hole_number: 10..18) }
end
