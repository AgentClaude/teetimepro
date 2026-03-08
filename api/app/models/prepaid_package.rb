# frozen_string_literal: true

class PrepaidPackage < ApplicationRecord
  belongs_to :organization
  belongs_to :course, optional: true
  has_many :prepaid_purchases, dependent: :restrict_with_error

  enum :package_type, {
    round_pack: 0,
    time_pass: 1,
    value_card: 2
  }

  monetize :price_cents
  monetize :value_cents, allow_nil: true

  validates :name, presence: true
  validates :price_cents, presence: true, numericality: { greater_than: 0 }
  validates :rounds_included, presence: true, numericality: { greater_than: 0 }, if: :round_pack?
  validates :value_cents, presence: true, numericality: { greater_than: 0 }, if: :value_card?
  validates :max_players_per_round, numericality: { greater_than: 0, less_than_or_equal_to: 5 }

  scope :active, -> { where(active: true) }
  scope :available, -> {
    active
      .where("available_from IS NULL OR available_from <= ?", Time.current)
      .where("available_until IS NULL OR available_until >= ?", Time.current)
  }
  scope :for_organization, ->(org_id) { where(organization_id: org_id) }
  scope :for_course, ->(course_id) { where(course_id: [course_id, nil]) }

  def available?
    active? &&
      (available_from.nil? || available_from <= Time.current) &&
      (available_until.nil? || available_until >= Time.current)
  end

  def unlimited_rounds?
    time_pass?
  end

  def restricted_days
    restrictions.fetch("day_of_week", [])
  end

  def restricted_time_ranges
    restrictions.fetch("time_ranges", [])
  end

  def excluded_dates
    restrictions.fetch("excluded_dates", [])
  end

  def valid_for_date?(date)
    return true if restrictions.blank?

    day_name = date.strftime("%A").downcase
    return false if restricted_days.include?(day_name)
    return false if excluded_dates.include?(date.to_s)

    true
  end

  def valid_for_time?(time)
    ranges = restricted_time_ranges
    return true if ranges.blank?

    time_str = time.strftime("%H:%M")
    ranges.any? do |range|
      time_str >= range["start"] && time_str <= range["end"]
    end
  end
end
