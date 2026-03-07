class MemberAccountCharge < ApplicationRecord
  belongs_to :organization
  belongs_to :membership
  belongs_to :charged_by, class_name: 'User'
  belongs_to :fnb_tab, optional: true
  belongs_to :booking, optional: true

  enum :charge_type, { fnb: 'fnb', booking: 'booking', pro_shop: 'pro_shop', dues: 'dues', other: 'other' }
  enum :status, { pending: 'pending', posted: 'posted', voided: 'voided', paid: 'paid' }

  monetize :amount_cents

  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :charge_type, presence: true
  validates :status, presence: true
  validates :description, presence: true, length: { maximum: 500 }
  validates :notes, length: { maximum: 1000 }, allow_blank: true

  validate :organization_consistency
  validate :membership_is_active
  validate :cannot_void_already_voided

  scope :for_organization, ->(org) { where(organization: org) }
  scope :for_membership, ->(membership) { where(membership: membership) }
  scope :outstanding, -> { where(status: %w[pending posted]) }
  scope :recent, -> { order(created_at: :desc) }
  scope :in_date_range, ->(start_date, end_date) {
    where(created_at: start_date.beginning_of_day..end_date.end_of_day)
  }

  after_create :update_membership_balance
  after_update :adjust_membership_balance, if: :saved_change_to_status?

  def amount
    Money.new(amount_cents, amount_currency)
  end

  def voidable?
    pending? || posted?
  end

  def member_name
    membership&.user&.full_name
  end

  def member
    membership&.user
  end

  private

  def organization_consistency
    return unless membership && organization

    if membership.organization_id != organization.id
      errors.add(:membership, 'must belong to the same organization')
    end
  end

  def membership_is_active
    return unless membership

    unless membership.active?
      errors.add(:membership, 'must be active to accept charges')
    end
  end

  def cannot_void_already_voided
    return unless status_changed? && voided?

    if status_was == 'voided'
      errors.add(:status, 'charge is already voided')
    end
  end

  def update_membership_balance
    return if voided?

    membership.increment!(:account_balance_cents, amount_cents)
  end

  def adjust_membership_balance
    if voided? && status_before_last_save.in?(%w[pending posted])
      membership.decrement!(:account_balance_cents, amount_cents)
    end
  end
end
