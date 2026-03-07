class CalendarConnection < ApplicationRecord
  belongs_to :user

  PROVIDERS = %w[google apple].freeze
  
  validates :provider, inclusion: { in: PROVIDERS }
  validates :provider, uniqueness: { scope: :user_id }
  validates :access_token, presence: true, if: :enabled?

  scope :enabled, -> { where(enabled: true) }
  scope :for_provider, ->(provider) { where(provider: provider) }
  scope :google, -> { for_provider('google') }
  scope :apple, -> { for_provider('apple') }

  encrypts :access_token, :refresh_token

  def google?
    provider == 'google'
  end

  def apple?
    provider == 'apple'
  end

  def token_expired?
    return false unless token_expires_at
    token_expires_at <= Time.current
  end

  def needs_refresh?
    token_expired? && refresh_token.present?
  end

  def disable!
    update!(enabled: false)
  end

  def enable!
    update!(enabled: true)
  end
end