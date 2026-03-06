class Payment < ApplicationRecord
  belongs_to :booking

  enum :status, { pending: 0, completed: 1, failed: 2, refunded: 3, partially_refunded: 4 }

  monetize :amount_cents
  monetize :refund_amount_cents, allow_nil: true

  validates :stripe_payment_intent_id, presence: true, uniqueness: true

  def fully_refundable?
    completed? && refund_amount_cents.to_i.zero?
  end

  def remaining_refundable_amount
    amount_cents - refund_amount_cents.to_i
  end
end
