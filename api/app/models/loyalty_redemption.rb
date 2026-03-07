class LoyaltyRedemption < ApplicationRecord
  belongs_to :loyalty_account
  belongs_to :loyalty_reward
  belongs_to :booking, optional: true

  validates :code, presence: true, uniqueness: true
  validates :status, presence: true

  enum status: { pending: 0, applied: 1, expired: 2, cancelled: 3 }

  scope :active, -> { where(status: [:pending, :applied]) }
  scope :for_account, ->(account) { where(loyalty_account: account) }
  scope :for_reward, ->(reward) { where(loyalty_reward: reward) }
  scope :expiring_soon, -> { where('expires_at < ?', 1.week.from_now) }

  before_create :generate_code
  before_create :set_expiration

  def expired?
    expires_at && expires_at < Time.current
  end

  def can_be_applied?
    pending? && !expired?
  end

  def can_be_cancelled?
    pending? || applied?
  end

  def apply_to_booking!(booking)
    raise "Redemption cannot be applied" unless can_be_applied?
    
    transaction do
      update!(status: :applied, booking: booking)
    end
  end

  def cancel!
    raise "Redemption cannot be cancelled" unless can_be_cancelled?
    
    transaction do
      # Refund points if not already applied
      if pending?
        loyalty_account.add_points!(
          loyalty_reward.points_cost,
          description: "Refund for cancelled redemption: #{loyalty_reward.name}",
          source: self
        )
      end
      
      update!(status: :cancelled)
    end
  end

  def mark_expired!
    return unless pending? && expired?
    
    transaction do
      # Refund points for expired redemption
      loyalty_account.add_points!(
        loyalty_reward.points_cost,
        description: "Refund for expired redemption: #{loyalty_reward.name}",
        source: self
      )
      
      update!(status: :expired)
    end
  end

  def organization
    loyalty_account.organization
  end

  def user
    loyalty_account.user
  end

  private

  def generate_code
    self.code = "RED-#{SecureRandom.hex(4).upcase}"
  end

  def set_expiration
    # Redemptions expire in 30 days by default
    self.expires_at = 30.days.from_now
  end
end