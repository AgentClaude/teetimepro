# frozen_string_literal: true

class EmailMessage < ApplicationRecord
  belongs_to :email_campaign
  belongs_to :user

  enum :status, {
    pending: 0,
    sent: 1,
    delivered: 2,
    opened: 3,
    clicked: 4,
    bounced: 5,
    failed: 6
  }

  validates :to_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true

  scope :by_campaign, ->(campaign) { where(email_campaign: campaign) }
  scope :successful, -> { where(status: [:sent, :delivered, :opened, :clicked]) }
  scope :failed, -> { where(status: [:bounced, :failed]) }

  def delivered?
    %w[delivered opened clicked].include?(status)
  end

  def failed?
    %w[bounced failed].include?(status)
  end

  def mark_opened!
    update!(status: :opened, opened_at: Time.current) if sent? || delivered?
  end

  def mark_clicked!
    update!(status: :clicked, clicked_at: Time.current) unless failed?
  end

  def mark_delivered!
    update!(status: :delivered, delivered_at: Time.current) if sent?
  end

  def mark_bounced!(error_message = nil)
    update!(status: :bounced, error_message: error_message)
  end

  def mark_failed!(error_message = nil)
    update!(status: :failed, error_message: error_message)
  end

  def mark_sent!(message_id = nil)
    update!(status: :sent, sent_at: Time.current, message_id: message_id)
  end
end