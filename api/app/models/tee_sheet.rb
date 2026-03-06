class TeeSheet < ApplicationRecord
  belongs_to :course
  has_many :tee_times, dependent: :destroy

  validates :date, presence: true
  validates :date, uniqueness: { scope: :course_id }

  scope :for_date, ->(date) { where(date: date) }
  scope :upcoming, -> { where("date >= ?", Date.current) }

  def total_slots
    tee_times.count
  end

  def available_slots
    tee_times.where(status: [:available, :partially_booked]).count
  end

  def utilization_percentage
    return 0 if total_slots.zero?

    booked = tee_times.sum(:booked_players)
    capacity = tee_times.sum(:max_players)
    return 0 if capacity.zero?

    ((booked.to_f / capacity) * 100).round(1)
  end
end
