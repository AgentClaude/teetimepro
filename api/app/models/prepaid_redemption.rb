# frozen_string_literal: true

class PrepaidRedemption < ApplicationRecord
  belongs_to :prepaid_purchase
  belongs_to :booking
  belongs_to :user

  enum :redemption_type, {
    round: 0,
    value: 1
  }

  monetize :value_cents, allow_nil: true

  validates :rounds_used, numericality: { greater_than: 0 }, if: :round?
  validates :value_cents, presence: true, numericality: { greater_than: 0 }, if: :value?

  scope :for_booking, ->(booking_id) { where(booking_id: booking_id) }
  scope :for_purchase, ->(purchase_id) { where(prepaid_purchase_id: purchase_id) }
end
