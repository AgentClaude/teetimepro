class HandicapRevision < ApplicationRecord
  belongs_to :golfer_profile

  validates :handicap_index, presence: true, numericality: { in: -10.0..54.0 }
  validates :effective_date, presence: true
  validates :source, presence: true, inclusion: { in: %w[calculated manual imported] }
  validates :rounds_used, numericality: { greater_than_or_equal_to: 0 }

  scope :recent, -> { order(effective_date: :desc, created_at: :desc) }
  scope :for_period, ->(start_date, end_date) {
    where(effective_date: start_date..end_date)
  }
end
