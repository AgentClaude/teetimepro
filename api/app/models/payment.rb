class Payment < ApplicationRecord
  belongs_to :booking
  belongs_to :organization, optional: true
  belongs_to :user, optional: true
  has_many :accounting_syncs, as: :syncable, dependent: :destroy

  enum :status, {
    pending: 0,
    authorized: 5,
    captured: 6,
    refunded: 3,
    failed: 2,
    cancelled: 7,
    # Legacy values kept for backward compatibility
    completed: 1,
    partially_refunded: 4
  }

  enum :payment_method, {
    card: 0,
    cash: 1,
    account: 2
  }, prefix: true

  enum :provider, {
    stripe: 0,
    manual: 1
  }, prefix: true

  monetize :amount_cents
  monetize :refund_amount_cents, allow_nil: true

  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :stripe_payment_intent_id, uniqueness: true, allow_nil: true
  validates :provider_transaction_id, uniqueness: true, allow_nil: true

  scope :for_booking, ->(booking_id) { where(booking_id: booking_id) }
  scope :by_status, ->(status) { where(status: status) }
  scope :for_organization, ->(org_id) { where(organization_id: org_id) }

  def fully_refundable?
    (completed? || captured?) && refund_amount_cents.to_i.zero?
  end

  def remaining_refundable_amount
    amount_cents - refund_amount_cents.to_i
  end

  def capturable?
    authorized?
  end

  def refundable?
    (completed? || captured?) && remaining_refundable_amount.positive?
  end
end
