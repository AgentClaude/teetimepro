# frozen_string_literal: true

class TeeTimeBlock < ApplicationRecord
  belongs_to :organization
  belongs_to :course
  belongs_to :created_by, class_name: "User"
  has_many :tee_times, dependent: :nullify

  enum :block_type, { maintenance: 0, event: 1, weather: 2, other: 3 }

  validates :reason, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 2000 }
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :block_type, presence: true

  validate :ends_at_after_starts_at
  validate :course_belongs_to_organization
  validate :no_overlapping_blocks, on: :create

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :current, -> { active.where("ends_at > ?", Time.current) }
  scope :upcoming, -> { active.where("starts_at > ?", Time.current) }
  scope :for_course, ->(course_id) { where(course_id: course_id) }
  scope :overlapping, ->(starts_at, ends_at) {
    where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
  }
  scope :by_type, ->(type) { where(block_type: type) }

  def duration_minutes
    ((ends_at - starts_at) / 60).to_i
  end

  def currently_active?
    active? && starts_at <= Time.current && ends_at > Time.current
  end

  def past?
    ends_at <= Time.current
  end

  def future?
    starts_at > Time.current
  end

  private

  def ends_at_after_starts_at
    return unless starts_at.present? && ends_at.present?

    if ends_at <= starts_at
      errors.add(:ends_at, "must be after start time")
    end
  end

  def course_belongs_to_organization
    return unless course.present? && organization.present?

    unless course.organization_id == organization.id
      errors.add(:course, "must belong to the organization")
    end
  end

  def no_overlapping_blocks
    return unless course.present? && starts_at.present? && ends_at.present?

    overlapping = TeeTimeBlock.active
                              .for_course(course_id)
                              .overlapping(starts_at, ends_at)

    if overlapping.exists?
      errors.add(:base, "Overlapping block already exists for this time range")
    end
  end
end
