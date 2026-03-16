class RangefinderDevice < ApplicationRecord
  belongs_to :organization

  has_many :player_locations, dependent: :nullify

  enum :device_type, {
    handheld_gps: 0,
    cart_gps: 1,
    watch_gps: 2,
    laser_rangefinder: 3,
    bluetooth_beacon: 4
  }

  enum :status, {
    active: 0,
    inactive: 1,
    maintenance: 2,
    retired: 3
  }

  validates :device_id, presence: true, uniqueness: { scope: :organization_id }
  validates :name, presence: true
  validates :device_type, presence: true
  validates :battery_level, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  scope :online, -> { where(status: :active).where("last_seen_at > ?", 15.minutes.ago) }

  def online?
    active? && last_seen_at.present? && last_seen_at > 15.minutes.ago
  end

  def touch_seen!
    update!(last_seen_at: Time.current)
  end
end
