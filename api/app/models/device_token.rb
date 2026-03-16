# frozen_string_literal: true

class DeviceToken < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum :platform, { ios: 0, android: 1 }

  validates :token, presence: true, uniqueness: true
  validates :platform, presence: true

  scope :active, -> { where(active: true) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_organization, ->(org) { where(organization: org) }

  def touch_last_used!
    update_column(:last_used_at, Time.current)
  end

  def deactivate!
    update!(active: false)
  end
end
