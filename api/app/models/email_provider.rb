# frozen_string_literal: true

class EmailProvider < ApplicationRecord
  belongs_to :organization

  PROVIDER_TYPES = %w[sendgrid mailchimp].freeze
  VERIFICATION_STATUSES = %w[pending verified failed].freeze

  enum :provider_type, {
    sendgrid: "sendgrid",
    mailchimp: "mailchimp"
  }

  validates :provider_type, presence: true, inclusion: { in: PROVIDER_TYPES }
  validates :api_key, presence: true
  validates :from_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :verification_status, inclusion: { in: VERIFICATION_STATUSES }
  validates :provider_type, uniqueness: { scope: :organization_id, message: "already configured for this organization" }

  scope :active, -> { where(is_active: true) }
  scope :verified, -> { where(verification_status: "verified") }
  scope :by_organization, ->(org) { where(organization: org) }

  before_save :ensure_single_default

  # Get the adapter instance for this provider
  def adapter
    case provider_type
    when "sendgrid"
      EmailProviders::SendgridAdapter.new(self)
    when "mailchimp"
      EmailProviders::MailchimpAdapter.new(self)
    else
      raise "Unknown provider type: #{provider_type}"
    end
  end

  def verify!
    result = adapter.verify_credentials
    if result[:success]
      update!(verification_status: "verified", last_verified_at: Time.current)
    else
      update!(verification_status: "failed")
    end
    result
  end

  def masked_api_key
    return nil if api_key.blank?

    key = api_key
    if key.length > 8
      "#{key[0..3]}#{"*" * (key.length - 8)}#{key[-4..]}"
    else
      "*" * key.length
    end
  end

  private

  def ensure_single_default
    return unless is_default? && is_default_changed?

    organization.email_providers.where.not(id: id).update_all(is_default: false)
  end
end
