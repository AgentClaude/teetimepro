class Membership < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  has_many :member_account_charges, dependent: :restrict_with_error

  enum :tier, { basic: 0, silver: 1, gold: 2, platinum: 3 }
  enum :status, { active: 0, expired: 1, suspended: 2, cancelled: 3 }

  monetize :price_cents
  monetize :account_balance_cents, allow_nil: true
  monetize :credit_limit_cents, allow_nil: true

  validates :starts_at, presence: true
  validates :ends_at, presence: true

  scope :active, -> { where(status: :active).where("ends_at > ?", Time.current) }
  scope :expiring_soon, -> { active.where("ends_at <= ?", 30.days.from_now) }
  scope :with_balance, -> { where("account_balance_cents > 0") }

  def days_remaining
    return 0 if expired? || cancelled?

    (ends_at.to_date - Date.current).to_i
  end

  def available_credit_cents
    credit_limit_cents - account_balance_cents
  end

  def available_credit
    Money.new(available_credit_cents, 'USD')
  end

  def account_balance
    Money.new(account_balance_cents, 'USD')
  end

  def credit_limit
    Money.new(credit_limit_cents, 'USD')
  end

  def can_charge?(amount_cents)
    active? && (account_balance_cents + amount_cents) <= credit_limit_cents
  end

  def outstanding_charges
    member_account_charges.outstanding
  end
end
