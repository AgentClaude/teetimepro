class LoyaltyProgram < ApplicationRecord
  belongs_to :organization
  has_many :loyalty_accounts, dependent: :destroy
  has_many :loyalty_rewards, dependent: :destroy

  validates :name, presence: true
  validates :points_per_dollar, presence: true, numericality: { greater_than: 0 }
  validates :tier_thresholds, presence: true

  scope :active, -> { where(is_active: true) }
  scope :for_organization, ->(org) { where(organization: org) }

  def default_tier_thresholds
    {
      "silver" => 500,
      "gold" => 2000,
      "platinum" => 5000
    }
  end

  def tier_for_points(lifetime_points)
    return "platinum" if lifetime_points >= tier_thresholds["platinum"]
    return "gold" if lifetime_points >= tier_thresholds["gold"]
    return "silver" if lifetime_points >= tier_thresholds["silver"]
    "bronze"
  end

  def points_needed_for_next_tier(current_points)
    current_tier = tier_for_points(current_points)
    
    case current_tier
    when "bronze"
      tier_thresholds["silver"] - current_points
    when "silver"
      tier_thresholds["gold"] - current_points
    when "gold"
      tier_thresholds["platinum"] - current_points
    else
      0 # already at highest tier
    end
  end
end