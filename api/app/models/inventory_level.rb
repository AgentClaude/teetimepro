class InventoryLevel < ApplicationRecord
  belongs_to :organization
  belongs_to :pos_product
  belongs_to :course
  belongs_to :last_counted_by, class_name: 'User', optional: true

  validates :current_stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reserved_stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reorder_point, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reorder_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :average_cost_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :last_cost_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  validate :organization_consistency
  validate :uniqueness_per_product_and_course

  scope :for_organization, ->(org) { where(organization: org) }
  scope :for_course, ->(course) { where(course: course) }
  scope :low_stock, -> { where('current_stock <= reorder_point') }
  scope :out_of_stock, -> { where(current_stock: 0) }
  scope :with_stock, -> { where('current_stock > 0') }

  # Class method to refresh inventory level for a specific product/course
  def self.refresh_for_product!(product, course)
    level = find_or_initialize_by(
      organization: product.organization,
      pos_product: product,
      course: course
    )

    # Calculate current stock from movements
    total_movements = InventoryMovement
      .where(pos_product: product, course: course)
      .sum(:quantity)

    level.current_stock = [total_movements, 0].max

    # Calculate average cost (weighted average)
    positive_movements = InventoryMovement
      .where(pos_product: product, course: course)
      .where('quantity > 0')
      .where.not(unit_cost_cents: nil)

    if positive_movements.exists?
      total_cost = positive_movements.sum('quantity * unit_cost_cents')
      total_quantity = positive_movements.sum(:quantity)
      level.average_cost_cents = total_quantity > 0 ? (total_cost / total_quantity).round(2) : nil

      # Last cost from most recent receipt
      last_receipt = positive_movements.order(created_at: :desc).first
      level.last_cost_cents = last_receipt&.unit_cost_cents
    end

    level.save!
    level
  end

  def available_stock
    current_stock - reserved_stock
  end

  def needs_reorder?
    current_stock <= reorder_point
  end

  def stock_value_cents
    return 0 unless average_cost_cents && current_stock > 0
    (average_cost_cents * current_stock).round(2)
  end

  def stock_value_amount
    Money.new(stock_value_cents, 'USD')
  end

  def average_cost_amount
    return nil unless average_cost_cents
    Money.new(average_cost_cents, 'USD')
  end

  def last_cost_amount
    return nil unless last_cost_cents
    Money.new(last_cost_cents, 'USD')
  end

  def stock_status
    return 'out_of_stock' if current_stock == 0
    return 'low_stock' if needs_reorder?
    'in_stock'
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

  def uniqueness_per_product_and_course
    return unless pos_product && course

    existing = self.class.where(pos_product: pos_product, course: course)
    existing = existing.where.not(id: id) if persisted?

    if existing.exists?
      errors.add(:base, 'Inventory level already exists for this product and course')
    end
  end
end