class ApiKey < ApplicationRecord
  belongs_to :organization

  validates :name, presence: true
  validates :token, presence: true, uniqueness: true

  before_create :generate_token

  scope :active, -> { where(active: true) }

  def self.authenticate(token)
    active.find_by(token: token)&.tap do |key|
      key.update_column(:last_used_at, Time.current)
    end
  end

  def revoke!
    update!(active: false)
  end

  def self.generate_secure_token
    "tp_#{SecureRandom.urlsafe_base64(48)}"
  end

  private

  def generate_token
    self.token ||= self.class.generate_secure_token
  end
end