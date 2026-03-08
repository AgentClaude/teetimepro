# frozen_string_literal: true

class PrepaidPurchase < ApplicationRecord
  belongs_to :prepaid_package
  belongs_to :organization
  belongs_to :user
  belongs_to :payment, optional: true
  has_many :prepaid_redemptions, dependent: :restrict_with_error

  enum :status, {
    active: 0,
    expired: 1,
    fully_redeemed: 2,
    cancelled: 3,
    suspended: 4
  }

  monetize :balance_cents, allow_nil: true

  validates :code, presence: true, uniqueness: true
  validates :purchased_at, presence: true
  validates :rounds_remaining, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :generate_code, on: :create

  scope :usable, -> { where(status: :active).where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_organization, ->(org_id) { where(organization_id: org_id) }
  scope :expiring_soon, -> { active.where("expires_at <= ?", 30.days.from_now).where("expires_at > ?", Time.current) }

  delegate :package_type, :round_pack?, :time_pass?, :value_card?,
           :max_players_per_round, :transferable?, :name, to: :prepaid_package

  def usable?
    active? && !expired_by_date?
  end

  def expired_by_date?
    expires_at.present? && expires_at <= Time.current
  end

  def has_rounds?
    return true if time_pass?
    return false unless round_pack?

    rounds_remaining.present? && rounds_remaining.positive?
  end

  def has_balance?(amount_cents = 1)
    return false unless value_card?

    balance_cents.present? && balance_cents >= amount_cents
  end

  def can_redeem_for_booking?(booking)
    return false unless usable?

    package = prepaid_package
    tee_time = booking.tee_time

    # Check course restriction
    if package.course_id.present? && package.course_id != tee_time.course.id
      return false
    end

    # Check date/time restrictions
    return false unless package.valid_for_date?(tee_time.starts_at.to_date)
    return false unless package.valid_for_time?(tee_time.starts_at)

    # Check availability
    if round_pack?
      has_rounds?
    elsif value_card?
      has_balance?
    else
      true # time_pass
    end
  end

  def total_rounds_used
    prepaid_redemptions.sum(:rounds_used)
  end

  def total_value_redeemed_cents
    prepaid_redemptions.sum(:value_cents)
  end

  private

  def generate_code
    self.code ||= "PP-#{SecureRandom.alphanumeric(8).upcase}"
  end
end
