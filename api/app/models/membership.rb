class Membership < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  enum :tier, { basic: 0, silver: 1, gold: 2, platinum: 3 }
  enum :status, { active: 0, expired: 1, suspended: 2, cancelled: 3 }

  monetize :price_cents

  validates :starts_at, presence: true
  validates :ends_at, presence: true

  scope :active, -> { where(status: :active).where("ends_at > ?", Time.current) }
  scope :expiring_soon, -> { active.where("ends_at <= ?", 30.days.from_now) }

  def days_remaining
    return 0 if expired? || cancelled?

    (ends_at.to_date - Date.current).to_i
  end
end
