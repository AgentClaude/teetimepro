class MarketplaceListing < ApplicationRecord
  belongs_to :marketplace_connection
  belongs_to :tee_time

  enum :status, { pending: 0, listed: 1, booked: 2, expired: 3, error: 4, cancelled: 5 }

  monetize :listed_price_cents, allow_nil: true

  validates :tee_time_id, uniqueness: { scope: :marketplace_connection_id,
                                         message: "already listed on this marketplace" }

  scope :active_listings, -> { where(status: [:pending, :listed]) }
  scope :for_connection, ->(connection) { where(marketplace_connection: connection) }

  delegate :provider, :provider_label, to: :marketplace_connection

  def commission_rate_percent
    return 0 unless commission_rate_bps
    commission_rate_bps / 100.0
  end

  def estimated_commission_cents
    return 0 unless listed_price_cents && commission_rate_bps
    (listed_price_cents * commission_rate_bps / 10_000.0).ceil
  end

  def net_revenue_cents
    return listed_price_cents unless listed_price_cents
    listed_price_cents - estimated_commission_cents
  end

  def mark_listed!(external_id)
    update!(
      status: :listed,
      external_listing_id: external_id,
      listed_at: Time.current
    )
  end

  def mark_booked!
    update!(status: :booked)
  end

  def mark_expired!
    update!(status: :expired)
  end

  def mark_cancelled!
    update!(status: :cancelled)
  end
end
