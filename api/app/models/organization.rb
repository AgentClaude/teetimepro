class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :courses, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :webhook_endpoints, dependent: :destroy
  has_many :sms_campaigns, dependent: :destroy
  has_many :email_campaigns, dependent: :destroy
  has_many :email_providers, dependent: :destroy
  has_many :email_templates, dependent: :destroy
  has_many :voice_call_logs, dependent: :destroy
  has_many :voice_handoffs, dependent: :destroy
  has_many :tournaments, dependent: :destroy
  has_many :accounting_integrations, dependent: :destroy
  has_many :golfer_segments, dependent: :destroy
  has_many :pricing_rules, dependent: :destroy
  has_many :fnb_tabs, dependent: :destroy
  has_many :member_account_charges, dependent: :destroy
  has_many :pos_products, dependent: :destroy
  has_many :marketplace_connections, dependent: :destroy
  has_many :call_recordings, dependent: :destroy
  has_many :call_transcriptions, dependent: :destroy
  has_many :loyalty_programs, dependent: :destroy
  has_many :loyalty_accounts, dependent: :destroy
  has_many :loyalty_rewards, dependent: :destroy
  has_many :waitlist_entries, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :stripe_account_id, uniqueness: true, allow_nil: true

  before_validation :generate_slug, on: :create

  # Tenant scoping helper
  def self.current
    RequestStore.store[:current_organization]
  end

  def self.current=(org)
    RequestStore.store[:current_organization] = org
  end

  private

  def generate_slug
    return if slug.present?

    base_slug = name&.parameterize
    self.slug = base_slug
    counter = 1
    while Organization.exists?(slug: self.slug)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end
end
