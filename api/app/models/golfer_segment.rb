# frozen_string_literal: true

class GolferSegment < ApplicationRecord
  belongs_to :organization
  belongs_to :created_by, class_name: "User"
  has_many :golfer_segment_memberships, dependent: :destroy
  has_many :members, through: :golfer_segment_memberships, source: :user

  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :filter_criteria, presence: true

  scope :by_organization, ->(org) { where(organization: org) }
  scope :dynamic, -> { where(is_dynamic: true) }
  scope :static, -> { where(is_dynamic: false) }

  # Supported filter keys:
  # - booking_count_min / booking_count_max (integer)
  # - last_booking_within_days / last_booking_before_days (integer)
  # - membership_tier (string or array of strings)
  # - membership_status (string: "active", "expired", "none")
  # - total_spent_min / total_spent_max (integer, in cents)
  # - signup_within_days / signup_before_days (integer)
  # - role (string or array)
  # - handicap_min / handicap_max (float)
  VALID_FILTER_KEYS = %w[
    booking_count_min booking_count_max
    last_booking_within_days last_booking_before_days
    membership_tier membership_status
    total_spent_min total_spent_max
    signup_within_days signup_before_days
    role
    handicap_min handicap_max
  ].freeze

  validate :validate_filter_criteria

  private

  def validate_filter_criteria
    return if filter_criteria.blank?

    unknown_keys = filter_criteria.keys - VALID_FILTER_KEYS
    if unknown_keys.any?
      errors.add(:filter_criteria, "contains unknown keys: #{unknown_keys.join(', ')}")
    end
  end
end
