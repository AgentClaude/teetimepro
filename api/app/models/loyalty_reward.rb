class LoyaltyReward < ApplicationRecord
  belongs_to :organization
  has_many :loyalty_redemptions, dependent: :destroy

  validates :name, presence: true
  validates :points_cost, presence: true, numericality: { greater_than: 0 }
  validates :reward_type, presence: true
  validates :discount_value, presence: true, numericality: { greater_than: 0 }, 
            if: -> { discount_percentage? || discount_fixed? || pro_shop_credit? }

  enum :reward_type, { 
    discount_percentage: 0, 
    discount_fixed: 1, 
    free_round: 2, 
    pro_shop_credit: 3 
  }

  scope :active, -> { where(is_active: true) }
  scope :for_organization, ->(org) { where(organization: org) }
  scope :by_type, ->(type) { where(reward_type: type) }
  scope :affordable_for, ->(points_balance) { where('points_cost <= ?', points_balance) }

  def can_be_redeemed_by?(user)
    return false unless is_active?
    return true if max_redemptions_per_user.nil?

    user_redemption_count = loyalty_redemptions
      .joins(:loyalty_account)
      .where(loyalty_accounts: { user: user })
      .where.not(status: :cancelled)
      .count

    user_redemption_count < max_redemptions_per_user
  end

  def discount_display
    case reward_type
    when "discount_percentage"
      "#{discount_value}% off"
    when "discount_fixed"
      "$#{discount_value / 100.0}"
    when "free_round"
      "Free round of golf"
    when "pro_shop_credit"
      "$#{discount_value / 100.0} pro shop credit"
    end
  end

  def redemption_limit_reached_for?(user)
    return false if max_redemptions_per_user.nil?
    
    !can_be_redeemed_by?(user)
  end

  def remaining_redemptions_for(user)
    return nil if max_redemptions_per_user.nil?

    user_redemption_count = loyalty_redemptions
      .joins(:loyalty_account)
      .where(loyalty_accounts: { user: user })
      .where.not(status: :cancelled)
      .count

    [max_redemptions_per_user - user_redemption_count, 0].max
  end
end