class ApiKey < ApplicationRecord
  belongs_to :organization

  validates :name, presence: true
  validates :key_digest, presence: true, uniqueness: true
  validates :prefix, presence: true, length: { is: 8 }

  before_validation :generate_key_and_digest, on: :create

  scope :active, -> { where(active: true).where("expires_at IS NULL OR expires_at > ?", Time.current) }

  # Rate limit mappings
  RATE_LIMITS = {
    'standard' => 60,
    'premium' => 300,
    'enterprise' => 1000
  }.freeze

  def self.authenticate(key)
    return nil unless key&.start_with?('tp_')

    digest = Digest::SHA256.hexdigest(key)
    active.find_by(key_digest: digest)&.tap do |api_key|
      api_key.update_column(:last_used_at, Time.current)
    end
  end

  def self.generate_unique_token
    "tp_#{SecureRandom.urlsafe_base64(48)}"
  end

  def rate_limit
    RATE_LIMITS[rate_limit_tier] || RATE_LIMITS['standard']
  end

  def has_scope?(scope)
    return true if scopes.blank? # Legacy keys without scopes have full access
    scopes.include?(scope.to_s)
  end

  def revoke!
    update!(active: false)
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  # Returns the raw key only during creation, never again
  def display_key
    @raw_key if @raw_key_created
  end

  alias_method :key, :display_key

  private

  def generate_key_and_digest
    return if key_digest.present?

    raw_key = self.class.generate_unique_token
    @raw_key = raw_key
    @raw_key_created = true

    self.key_digest = Digest::SHA256.hexdigest(raw_key)
    self.prefix = raw_key[0..7]
  end
end
