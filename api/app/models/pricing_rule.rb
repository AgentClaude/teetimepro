class PricingRule < ApplicationRecord
  belongs_to :organization
  belongs_to :course, optional: true

  RULE_TYPES = %w[
    time_of_day
    day_of_week
    occupancy
    weather
    advance_booking
    last_minute
  ].freeze

  validates :name, presence: true
  validates :rule_type, presence: true, inclusion: { in: RULE_TYPES }
  validates :multiplier, presence: true, numericality: { greater_than: 0 }
  validates :priority, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :end_date_after_start_date

  monetize :flat_adjustment_cents, allow_nil: true

  scope :active, -> { where(active: true) }
  scope :for_organization, ->(org_id) { where(organization_id: org_id) }
  scope :for_course, ->(course_id) { where(course_id: course_id) }
  scope :by_priority, -> { order(priority: :desc) }
  scope :valid_for_date, ->(date) do
    where(
      '(start_date IS NULL OR start_date <= ?) AND (end_date IS NULL OR end_date >= ?)',
      date, date
    )
  end

  def applicable_to_tee_time?(tee_time)
    return false unless active?
    return false unless valid_for_date?(tee_time.date)
    return false unless course_matches?(tee_time.course)

    case rule_type
    when 'time_of_day'
      check_time_of_day(tee_time)
    when 'day_of_week'
      check_day_of_week(tee_time)
    when 'occupancy'
      check_occupancy(tee_time)
    when 'weather'
      check_weather(tee_time)
    when 'advance_booking'
      check_advance_booking(tee_time)
    when 'last_minute'
      check_last_minute(tee_time)
    else
      false
    end
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date

    errors.add(:end_date, 'must be after start date') if end_date < start_date
  end

  def valid_for_date?(date)
    return true if start_date.nil? && end_date.nil?
    return date >= start_date if end_date.nil?
    return date <= end_date if start_date.nil?

    (start_date..end_date).cover?(date)
  end

  def course_matches?(course)
    self.course.nil? || self.course == course
  end

  def check_time_of_day(tee_time)
    return true if conditions['hours'].blank?

    start_hour = conditions.dig('hours', 'start')
    end_hour = conditions.dig('hours', 'end')

    return true if start_hour.nil? && end_hour.nil?

    hour = tee_time.starts_at.hour
    return hour >= start_hour if end_hour.nil?
    return hour <= end_hour if start_hour.nil?

    (start_hour..end_hour).cover?(hour)
  end

  def check_day_of_week(tee_time)
    days = conditions['days']
    return true if days.blank?

    # Convert Date#wday (0=Sunday) to array index
    wday = tee_time.date.wday
    day_names = %w[sunday monday tuesday wednesday thursday friday saturday]
    current_day = day_names[wday]

    Array(days).include?(current_day)
  end

  def check_occupancy(tee_time)
    threshold = conditions['threshold']
    return true if threshold.blank?

    # Calculate occupancy rate for the tee sheet
    sheet = tee_time.tee_sheet
    total_spots = sheet.tee_times.sum(:max_players)
    booked_spots = sheet.tee_times.sum(:booked_players)

    return true if total_spots.zero?

    occupancy_rate = (booked_spots.to_f / total_spots * 100).round(2)

    case conditions['operator']
    when 'greater_than'
      occupancy_rate > threshold
    when 'less_than'
      occupancy_rate < threshold
    when 'equal'
      occupancy_rate == threshold
    else
      true
    end
  end

  def check_weather(tee_time)
    # Weather conditions would be integrated with a weather service
    # For now, always return true
    true
  end

  def check_advance_booking(tee_time)
    hours = conditions['hours']
    return true if hours.blank?

    hours_until = ((tee_time.starts_at - Time.current) / 1.hour).round
    operator = conditions['operator'] || 'greater_than'

    case operator
    when 'greater_than'
      hours_until > hours
    when 'less_than'
      hours_until < hours
    when 'equal'
      hours_until == hours
    else
      true
    end
  end

  def check_last_minute(tee_time)
    hours = conditions['hours'] || 2
    hours_until = ((tee_time.starts_at - Time.current) / 1.hour).round
    hours_until <= hours
  end
end