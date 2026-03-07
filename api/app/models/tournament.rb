class Tournament < ApplicationRecord
  belongs_to :course
  belongs_to :organization
  belongs_to :created_by, class_name: "User"
  has_many :tournament_entries, dependent: :destroy
  has_many :participants, through: :tournament_entries, source: :user

  enum :format, { stroke: 0, match_play: 1, scramble: 2, best_ball: 3, stableford: 4 }
  enum :status, {
    draft: 0,
    registration_open: 1,
    registration_closed: 2,
    in_progress: 3,
    completed: 4,
    cancelled: 5
  }

  monetize :entry_fee_cents

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :format, presence: true
  validates :status, presence: true
  validates :holes, inclusion: { in: [9, 18] }
  validates :min_participants, numericality: { greater_than: 0 }
  validates :max_participants, numericality: { greater_than: 0 }, allow_nil: true
  validates :team_size, numericality: { greater_than: 0 }
  validates :max_handicap, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :end_date_after_start_date
  validate :registration_window_valid
  validate :team_size_matches_format
  validate :max_gte_min_participants

  scope :for_organization, ->(org) { where(organization: org) }
  scope :upcoming, -> { where("start_date >= ?", Date.current).where.not(status: :cancelled) }
  scope :active, -> { where(status: [:registration_open, :registration_closed, :in_progress]) }
  scope :past, -> { where("end_date < ?", Date.current) }

  def full?
    return false if max_participants.nil?

    entries_count >= max_participants
  end

  def entries_count
    tournament_entries.where.not(status: :withdrawn).count
  end

  def registration_available?
    registration_open? && !full? && registration_window_active?
  end

  def registration_window_active?
    now = Time.current
    after_open = registration_opens_at.nil? || now >= registration_opens_at
    before_close = registration_closes_at.nil? || now <= registration_closes_at
    after_open && before_close
  end

  def team_format?
    scramble? || best_ball?
  end

  def individual_format?
    stroke? || match_play?
  end

  def days
    (end_date - start_date).to_i + 1
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date

    errors.add(:end_date, "must be on or after start date") if end_date < start_date
  end

  def registration_window_valid
    return unless registration_opens_at && registration_closes_at

    if registration_closes_at <= registration_opens_at
      errors.add(:registration_closes_at, "must be after registration opens")
    end
  end

  def team_size_matches_format
    return unless format.present? && team_size.present?

    if individual_format? && team_size != 1
      errors.add(:team_size, "must be 1 for individual formats")
    end

    if team_format? && team_size < 2
      errors.add(:team_size, "must be at least 2 for team formats")
    end
  end

  def max_gte_min_participants
    return unless max_participants && min_participants

    if max_participants < min_participants
      errors.add(:max_participants, "must be greater than or equal to minimum participants")
    end
  end
end
