# frozen_string_literal: true

class SmsMessage < ApplicationRecord
  belongs_to :sms_campaign, counter_cache: false
  belongs_to :user

  enum :status, {
    pending: 0,
    queued: 1,
    sent: 2,
    delivered: 3,
    failed: 4,
    undelivered: 5
  }

  validates :to_phone, presence: true
  validates :user_id, uniqueness: { scope: :sms_campaign_id }

  scope :by_campaign, ->(campaign) { where(sms_campaign: campaign) }

  def terminal?
    delivered? || failed? || undelivered?
  end
end
