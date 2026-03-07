class LoyaltyAccount < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  has_many :loyalty_transactions, dependent: :destroy
  has_many :loyalty_redemptions, dependent: :destroy

  validates :points_balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :lifetime_points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { scope: :organization_id }

  enum :tier, { bronze: 0, silver: 1, gold: 2, platinum: 3 }

  scope :for_organization, ->(org) { where(organization: org) }
  scope :by_tier, ->(tier) { where(tier: tier) }

  def loyalty_program
    organization.loyalty_programs.active.first
  end

  def can_afford?(points_cost)
    points_balance >= points_cost
  end

  def add_points!(amount, description:, source: nil)
    transaction do
      self.points_balance += amount
      self.lifetime_points += amount if amount > 0
      save!

      loyalty_transactions.create!(
        transaction_type: :earn,
        points: amount,
        description: description,
        balance_after: points_balance,
        source: source
      )

      update_tier!
    end
  end

  def deduct_points!(amount, description:, source: nil)
    raise ArgumentError, "Insufficient points" unless can_afford?(amount)

    transaction do
      self.points_balance -= amount
      save!

      loyalty_transactions.create!(
        transaction_type: :redeem,
        points: -amount,
        description: description,
        balance_after: points_balance,
        source: source
      )
    end
  end

  def adjust_points!(amount, description:, source: nil)
    transaction do
      self.points_balance += amount
      self.lifetime_points += amount if amount > 0
      save!

      loyalty_transactions.create!(
        transaction_type: :adjust,
        points: amount,
        description: description,
        balance_after: points_balance,
        source: source
      )

      update_tier!
    end
  end

  def recent_transactions(limit: 10)
    loyalty_transactions.order(created_at: :desc).limit(limit)
  end

  def tier_name
    tier.humanize
  end

  def points_needed_for_next_tier
    return 0 unless loyalty_program

    loyalty_program.points_needed_for_next_tier(lifetime_points)
  end

  private

  def update_tier!
    return unless loyalty_program

    new_tier = loyalty_program.tier_for_points(lifetime_points)
    update!(tier: new_tier)
  end
end