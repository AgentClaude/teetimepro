class AccountingIntegration < ApplicationRecord
  belongs_to :organization
  has_many :accounting_syncs, dependent: :destroy

  enum :provider, { quickbooks: 0, xero: 1 }
  enum :status, { disconnected: 0, connected: 1, error: 2 }

  # Encrypt sensitive OAuth data
  encrypts :access_token
  encrypts :refresh_token
  encrypts :realm_id
  encrypts :tenant_id

  validates :provider, presence: true, uniqueness: { scope: :organization_id }
  validates :organization, presence: true

  # Scopes
  scope :active, -> { where(status: :connected) }
  scope :for_organization, ->(org) { where(organization: org) }

  # Callbacks
  before_destroy :disconnect_integration

  # Check if the integration is connected and not in error state
  def connected?
    status == 'connected' && access_token.present?
  end

  # Check if tokens need refresh (assume 1 hour expiry for safety)
  def tokens_expired?
    return true if connected_at.blank?
    connected_at < 1.hour.ago
  end

  # Mark integration as connected
  def mark_connected!(company_info = {})
    update!(
      status: :connected,
      connected_at: Time.current,
      company_name: company_info[:company_name],
      country_code: company_info[:country_code],
      last_error_message: nil,
      last_error_at: nil
    )
  end

  # Mark integration as disconnected
  def mark_disconnected!
    update!(
      status: :disconnected,
      access_token: nil,
      refresh_token: nil,
      realm_id: nil,
      tenant_id: nil,
      connected_at: nil,
      last_sync_at: nil,
      last_error_message: nil,
      last_error_at: nil
    )
  end

  # Mark integration as having an error
  def mark_error!(error_message)
    update!(
      status: :error,
      last_error_message: error_message,
      last_error_at: Time.current
    )
  end

  # Update last sync timestamp
  def mark_synced!
    update!(last_sync_at: Time.current)
  end

  # Get account mapping for a specific category
  def account_for(category)
    account_mapping.dig(category.to_s, 'account_id')
  end

  # Set account mapping for a category
  def set_account_mapping(category, account_id, account_name)
    mapping = account_mapping.dup
    mapping[category.to_s] = {
      'account_id' => account_id,
      'account_name' => account_name
    }
    update!(account_mapping: mapping)
  end

  # Provider-specific company identifier
  def company_id
    case provider
    when 'quickbooks'
      realm_id
    when 'xero'
      tenant_id
    end
  end

  private

  def disconnect_integration
    # This could trigger a service to revoke tokens
    Rails.logger.info "Disconnecting #{provider} integration for organization #{organization_id}"
  end
end