class Booking < ApplicationRecord
  has_paper_trail ignore: [:updated_at, :created_at]

  belongs_to :tee_time
  belongs_to :user
  has_many :booking_players, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :fnb_tabs, dependent: :nullify
  has_many :accounting_syncs, as: :syncable, dependent: :destroy
  has_many :prepaid_redemptions, dependent: :destroy

  enum :status, { confirmed: 0, checked_in: 1, completed: 2, cancelled: 3, no_show: 4, pending_voice_confirmation: 5 }
  enum :booking_type, { online: 0, walk_on: 1, phone: 2, staff: 3 }

  belongs_to :created_by, class_name: "User", optional: true

  validates :players_count, presence: true, numericality: { in: 1..5 }
  validates :guest_name, presence: true, if: :walk_on?

  scope :walk_ons, -> { where(booking_type: :walk_on) }
  scope :walk_ons_today, -> {
    walk_ons.joins(tee_time: :tee_sheet)
            .where(tee_sheets: { date: Date.current })
  }

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

  # Convenience: returns the primary (most recent) payment
  def payment
    payments.order(created_at: :desc).first
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
    self.confirmation_code = SecureRandom.alphanumeric(8).upcase if confirmation_code.blank?
  end
end
