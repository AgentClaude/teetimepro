class PosProduct < ApplicationRecord
  belongs_to :organization
  belongs_to :course

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

  def in_stock?
    return true unless track_inventory

    stock_quantity.present? && stock_quantity > 0
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
