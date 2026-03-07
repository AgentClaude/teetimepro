module Accounting
  class ConnectService < ApplicationService
    attr_accessor :organization, :provider, :oauth_params

    validates :organization, presence: true
    validates :provider, presence: true, inclusion: { in: %w[quickbooks xero] }
    validates :oauth_params, presence: true

    def call
      validate_oauth_params!
      return failure(errors: errors.full_messages) if errors.any?

      begin
        exchange_oauth_code_for_tokens!
        create_or_update_integration!
        fetch_company_info!
        
        success(integration: @integration)
      rescue => e
        @integration&.mark_error!(e.message)
        failure(errors: ["Failed to connect to #{provider.titleize}: #{e.message}"])
      end
    end

    private

    def validate_oauth_params!
      case provider
      when 'quickbooks'
        validate_quickbooks_params!
      when 'xero'
        validate_xero_params!
      end
    end

    def validate_quickbooks_params!
      unless oauth_params[:code] && oauth_params[:state] && oauth_params[:realmId]
        errors.add(:oauth_params, 'Missing required QuickBooks OAuth parameters')
      end
    end

    def validate_xero_params!
      unless oauth_params[:code] && oauth_params[:state]
        errors.add(:oauth_params, 'Missing required Xero OAuth parameters')
      end
    end

    def exchange_oauth_code_for_tokens!
      case provider
      when 'quickbooks'
        exchange_quickbooks_tokens!
      when 'xero'
        exchange_xero_tokens!
      end
    end

    def exchange_quickbooks_tokens!
      # This would integrate with QuickBooks OAuth2 API
      # For now, we'll simulate the response
      @tokens = {
        access_token: "QB_#{oauth_params[:code]}_ACCESS",
        refresh_token: "QB_#{oauth_params[:code]}_REFRESH",
        expires_in: 3600
      }
      @realm_id = oauth_params[:realmId]
    end

    def exchange_xero_tokens!
      # This would integrate with Xero OAuth2 API  
      # For now, we'll simulate the response
      @tokens = {
        access_token: "XERO_#{oauth_params[:code]}_ACCESS",
        refresh_token: "XERO_#{oauth_params[:code]}_REFRESH",
        expires_in: 3600
      }
      
      # Would need to fetch tenant info from Xero
      @tenant_id = "XERO_TENANT_#{SecureRandom.hex(8)}"
    end

    def create_or_update_integration!
      @integration = organization.accounting_integrations
                                 .find_or_initialize_by(provider: provider)

      @integration.assign_attributes(
        access_token: @tokens[:access_token],
        refresh_token: @tokens[:refresh_token],
        realm_id: @realm_id,
        tenant_id: @tenant_id
      )

      @integration.save!
    end

    def fetch_company_info!
      case provider
      when 'quickbooks'
        fetch_quickbooks_company_info!
      when 'xero'
        fetch_xero_company_info!
      end

      @integration.mark_connected!(@company_info)
    end

    def fetch_quickbooks_company_info!
      # This would call QuickBooks API to get company info
      @company_info = {
        company_name: "Sample QuickBooks Company",
        country_code: "US"
      }
    end

    def fetch_xero_company_info!
      # This would call Xero API to get organization info
      @company_info = {
        company_name: "Sample Xero Organization", 
        country_code: "US"
      }
    end
  end
end
