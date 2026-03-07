class InventoryMovement < ApplicationRecord
  belongs_to :organization
  belongs_to :pos_product
  belongs_to :course
  belongs_to :performed_by, class_name: 'User'
  belongs_to :reference, polymorphic: true, optional: true

  validates :movement_type, presence: true,
            inclusion: { in: %w[receipt sale adjustment transfer_in transfer_out] }
  validates :quantity, presence: true, numericality: { other_than: 0 }
  validates :unit_cost_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :total_cost_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  validate :organization_consistency
  validate :quantity_direction_for_type

  enum :movement_type, {
    receipt: 'receipt',           # Stock coming in (positive quantity)
    sale: 'sale',                 # Stock sold (negative quantity)
    adjustment: 'adjustment',     # Manual adjustment (positive or negative)
    transfer_in: 'transfer_in',   # Transfer from another location (positive)
    transfer_out: 'transfer_out'  # Transfer to another location (negative)
  }

  scope :for_organization, ->(org) { where(organization: org) }
  scope :for_product, ->(product) { where(pos_product: product) }
  scope :for_course, ->(course) { where(course: course) }
  scope :positive_movements, -> { where('quantity > 0') }
  scope :negative_movements, -> { where('quantity < 0') }
  scope :recent, -> { order(created_at: :desc) }

  after_create :update_inventory_level
  after_update :update_inventory_level, if: :saved_change_to_quantity?
  after_destroy :update_inventory_level

  def positive_quantity?
    quantity > 0
  end

  def negative_quantity?
    quantity < 0
  end

  def unit_cost_amount
    return nil unless unit_cost_cents
    Money.new(unit_cost_cents, 'USD')
  end

  def total_cost_amount
    return nil unless total_cost_cents
    Money.new(total_cost_cents, 'USD')
  end

  def formatted_quantity
    sign = positive_quantity? ? '+' : ''
    "#{sign}#{quantity}"
  end

  private

  def organization_consistency
    return unless course && organization && pos_product

    unless course.organization_id == organization.id
      errors.add(:course, 'must belong to the same organization')
    end

    unless pos_product.organization_id == organization.id
      errors.add(:pos_product, 'must belong to the same organization')
    end
  end

  def quantity_direction_for_type
    case movement_type
    when 'receipt', 'transfer_in'
      errors.add(:quantity, 'must be positive for receipts and transfers in') if quantity <= 0
    when 'sale', 'transfer_out'
      errors.add(:quantity, 'must be negative for sales and transfers out') if quantity >= 0
    when 'adjustment'
      # Adjustments can be positive or negative, so no validation needed
    end
  end

  def update_inventory_level
    InventoryLevel.refresh_for_product!(pos_product, course)
  end
end