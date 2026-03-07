class FnbTabItem < ApplicationRecord
  belongs_to :fnb_tab
  belongs_to :added_by, class_name: 'User', foreign_key: 'added_by_id'

  validates :name, presence: true, length: { maximum: 255 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :category, presence: true, inclusion: { in: %w[food beverage other] }

  validate :total_cents_matches_calculation
  validate :tab_can_be_modified
  validate :organization_consistency

  enum category: { food: 'food', beverage: 'beverage', other: 'other' }

  scope :for_tab, ->(tab) { where(fnb_tab: tab) }
  scope :by_category, ->(cat) { where(category: cat) }
  scope :recent, -> { order(created_at: :desc) }

  before_validation :calculate_total_cents
  after_create :update_tab_total
  after_update :update_tab_total, if: :saved_change_to_quantity? || :saved_change_to_unit_price_cents?
  after_destroy :update_tab_total

  def unit_price_amount
    Money.new(unit_price_cents, 'USD')
  end

  def total_amount
    Money.new(total_cents, 'USD')
  end

  def line_total
    quantity * unit_price_cents
  end

  def organization
    fnb_tab&.organization
  end

  def course
    fnb_tab&.course
  end

  def can_be_modified?
    fnb_tab&.can_be_modified?
  end

  private

  def calculate_total_cents
    if quantity && unit_price_cents
      self.total_cents = quantity * unit_price_cents
    end
  end

  def total_cents_matches_calculation
    return unless quantity && unit_price_cents && total_cents
    
    expected_total = quantity * unit_price_cents
    if total_cents != expected_total
      errors.add(:total_cents, "should equal quantity (#{quantity}) × unit price (#{unit_price_cents}) = #{expected_total}")
    end
  end

  def tab_can_be_modified
    return unless fnb_tab
    
    unless fnb_tab.can_be_modified?
      errors.add(:fnb_tab, 'cannot be modified once closed or merged')
    end
  end

  def organization_consistency
    return unless added_by && fnb_tab
    
    if added_by.organization_id != fnb_tab.organization_id
      errors.add(:added_by, 'must belong to the same organization as the tab')
    end
  end

  def update_tab_total
    fnb_tab&.send(:calculate_total_cents)
    fnb_tab&.save! if fnb_tab&.changed?
  end
end