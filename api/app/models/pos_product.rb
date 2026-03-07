class PosProduct < ApplicationRecord
  belongs_to :organization
  belongs_to :course
  
  has_many :inventory_movements, dependent: :destroy
  has_many :inventory_levels, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :sku, presence: true, length: { maximum: 100 },
            uniqueness: { scope: :organization_id, case_sensitive: false }
  validates :barcode, length: { maximum: 100 },
            uniqueness: { scope: :organization_id, case_sensitive: false, allow_nil: true }
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :category, presence: true,
            inclusion: { in: %w[food beverage apparel equipment rental other] }

  validate :organization_consistency

  enum :category, {
    food: 'food',
    beverage: 'beverage',
    apparel: 'apparel',
    equipment: 'equipment',
    rental: 'rental',
    other: 'other'
  }

  scope :for_organization, ->(org) { where(organization: org) }
  scope :for_course, ->(course) { where(course: course) }
  scope :active, -> { where(active: true) }
  scope :by_category, ->(cat) { where(category: cat) }
  scope :search, ->(query) {
    where('name ILIKE :q OR sku ILIKE :q OR barcode ILIKE :q', q: "%#{query}%")
  }

  def price_amount
    Money.new(price_cents, 'USD')
  end

  def formatted_price
    "$#{(price_cents / 100.0).round(2)}"
  end

  def in_stock?(course = nil)
    return true unless track_inventory

    if course
      level = inventory_levels.find_by(course: course)
      return level&.current_stock.to_i > 0
    end

    # Fallback to legacy stock_quantity if no course specified
    stock_quantity.present? && stock_quantity > 0
  end

  def available_stock_for_course(course)
    return nil unless track_inventory
    
    level = inventory_levels.find_by(course: course)
    level&.available_stock || 0
  end

  def current_stock_for_course(course)
    return nil unless track_inventory
    
    level = inventory_levels.find_by(course: course)
    level&.current_stock || 0
  end

  def needs_reorder?(course = nil)
    return false unless track_inventory

    if course
      level = inventory_levels.find_by(course: course)
      return level&.needs_reorder? || false
    end

    # Check across all courses
    inventory_levels.any?(&:needs_reorder?)
  end

  def decrement_stock!(quantity = 1)
    return unless track_inventory
    return unless stock_quantity

    with_lock do
      new_qty = stock_quantity - quantity
      raise 'Insufficient stock' if new_qty < 0

      update!(stock_quantity: new_qty)
    end
  end

  private

  def organization_consistency
    return unless course && organization

    unless course.organization_id == organization.id
      errors.add(:course, 'must belong to the same organization')
    end
  end
end
