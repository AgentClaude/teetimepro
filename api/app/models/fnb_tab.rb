class FnbTab < ApplicationRecord
  belongs_to :organization
  belongs_to :course
  belongs_to :user, class_name: 'User', foreign_key: 'user_id' # Server who opened the tab
  has_many :fnb_tab_items, dependent: :destroy
  has_many :added_by_users, through: :fnb_tab_items, source: :added_by, class_name: 'User'

  validates :golfer_name, presence: true, length: { maximum: 255 }
  validates :status, presence: true, inclusion: { in: %w[open closed merged] }
  validates :total_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :opened_at, presence: true

  validate :closed_at_after_opened_at, if: :closed_at?
  validate :organization_consistency

  enum status: { open: 'open', closed: 'closed', merged: 'merged' }

  scope :for_organization, ->(org) { where(organization: org) }
  scope :for_course, ->(course) { where(course: course) }
  scope :recent, -> { order(opened_at: :desc) }
  scope :open_tabs, -> { where(status: 'open') }

  before_validation :set_opened_at_if_blank
  before_validation :calculate_total_cents
  after_update :touch_related_tabs, if: :saved_change_to_status?

  def total_amount
    Money.new(total_cents, 'USD')
  end

  def open?
    status == 'open'
  end

  def closed?
    status == 'closed'
  end

  def merged?
    status == 'merged'
  end

  def duration_in_minutes
    return nil unless closed_at && opened_at
    ((closed_at - opened_at) / 1.minute).round
  end

  def item_count
    fnb_tab_items.sum(:quantity)
  end

  def can_be_modified?
    open?
  end

  def close!
    update!(status: 'closed', closed_at: Time.current)
  end

  def merge!
    update!(status: 'merged', closed_at: Time.current)
  end

  private

  def set_opened_at_if_blank
    self.opened_at ||= Time.current
  end

  def calculate_total_cents
    self.total_cents = fnb_tab_items.sum { |item| item.quantity.to_i * item.unit_price_cents.to_i }
  end

  def closed_at_after_opened_at
    return unless opened_at && closed_at
    
    if closed_at <= opened_at
      errors.add(:closed_at, 'must be after opened at time')
    end
  end

  def organization_consistency
    return unless course && organization
    
    if course.organization_id != organization.id
      errors.add(:course, 'must belong to the same organization')
    end
  end

  def touch_related_tabs
    # Touch related records for cache invalidation if needed
    course&.touch
  end
end
