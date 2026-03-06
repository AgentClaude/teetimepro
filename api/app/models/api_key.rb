class ApiKey < ApplicationRecord
  belongs_to :organization

  validates :name, presence: true
  validates :key_digest, presence: true, uniqueness: true
  validates :prefix, presence: true, length: { is: 8 }
  validates :scopes, presence: true
  validates :rate_limit_tier, presence: true, inclusion: { in: %w[standard premium enterprise] }

  has_secure_token :key

  before_create :set_key_digest_and_prefix
  before_create :set_default_scopes

  scope :active, -> { where(active: true, expires_at: [nil, Time.current..]) }

  # Rate limit mappings
  RATE_LIMITS = {
    'standard' => 60,    # 60 requests per minute
    'premium' => 300,    # 300 requests per minute
    'enterprise' => 1000 # 1000 requests per minute
  }.freeze

  def self.authenticate(key)
    return nil unless key&.starts_with?('tp_')

    digest = Digest::SHA256.hexdigest(key)
    api_key = active.find_by(key_digest: digest)
    
    if api_key
      api_key.update_column(:last_used_at, Time.current)
      api_key
    end
  end

  def self.generate_unique_token
    "tp_#{SecureRandom.urlsafe_base64(48)}"
  end

  def rate_limit
    RATE_LIMITS[rate_limit_tier]
  end

  def has_scope?(scope)
    scopes.include?(scope.to_s)
  end

  def revoke!
    update!(active: false)
  end

  def expires_soon?
    expires_at && expires_at <= 7.days.from_now
  end

  def expired?
    expires_at && expires_at <= Time.current
  end

  # Returns the raw key only during creation, never again
  def display_key
    @raw_key if @raw_key_created
  end

  private

  def set_key_digest_and_prefix
    if key.present?
      @raw_key = key
      @raw_key_created = true
      
      self.key_digest = Digest::SHA256.hexdigest(key)
      self.prefix = key[0..7] # First 8 characters for identification
      
      # Clear the raw key attribute for security
      self.key = nil
    end
  end

  def set_default_scopes
    self.scopes = ['read'] if scopes.blank?
  end
end