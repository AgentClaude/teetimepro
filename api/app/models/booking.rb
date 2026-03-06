class Booking < ApplicationRecord
  belongs_to :tee_time
  belongs_to :user
  has_many :booking_players, dependent: :destroy
  has_one :payment, dependent: :destroy

  enum :status, { confirmed: 0, checked_in: 1, completed: 2, cancelled: 3, no_show: 4 }

  validates :players_count, presence: true, numericality: { in: 1..5 }

  monetize :total_cents

  before_create :generate_confirmation_code

  scope :upcoming, -> {
    joins(:tee_time)
      .where("tee_times.starts_at > ?", Time.current)
      .where.not(status: :cancelled)
  }

  scope :for_date, ->(date) {
    joins(tee_time: :tee_sheet)
      .where(tee_sheets: { date: date })
  }

  scope :for_organization, ->(org) {
    joins(tee_time: { tee_sheet: :course })
      .where(courses: { organization_id: org.id })
  }

  delegate :starts_at, to: :tee_time
  delegate :course, to: :tee_time
  
  def organization
    course.organization
  end

  def cancellable?
    confirmed? && starts_at > 24.hours.from_now
  end

  def refundable?
    cancellable? && payment&.completed?
  end

  def late_cancel?
    confirmed? && starts_at <= 24.hours.from_now && starts_at > Time.current
  end

  private

  def generate_confirmation_code
    self.confirmation_code = SecureRandom.alphanumeric(8).upcase
  end
end
