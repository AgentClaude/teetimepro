class LoyaltyTransaction < ApplicationRecord
  belongs_to :loyalty_account
  belongs_to :source, polymorphic: true, optional: true

  validates :points, presence: true
  validates :description, presence: true
  validates :balance_after, presence: true, numericality: { greater_than_or_equal_to: 0 }

  enum transaction_type: { earn: 0, redeem: 1, adjust: 2, expire: 3 }

  scope :for_account, ->(account) { where(loyalty_account: account) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(transaction_type: type) }

  def points_display
    case transaction_type
    when "earn", "adjust"
      points > 0 ? "+#{points}" : points.to_s
    when "redeem", "expire"
      "-#{points.abs}"
    else
      points.to_s
    end
  end

  def transaction_icon
    case transaction_type
    when "earn"
      "+"
    when "redeem"
      "-"
    when "adjust"
      points > 0 ? "+" : "-"
    when "expire"
      "⚠"
    end
  end

  def positive?
    points > 0
  end

  def negative?
    points < 0
  end
end