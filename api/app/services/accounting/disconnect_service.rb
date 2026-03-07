module Accounting
  class DisconnectService < ApplicationService
    attr_accessor :organization, :provider

    validates :organization, presence: true
    validates :provider, presence: true, inclusion: { in: %w[quickbooks xero] }

    def call
      return failure(errors: errors.full_messages) if errors.any?

      begin
        find_integration!
        return success(message: "No integration found") unless @integration

        revoke_tokens! if @integration.connected?
        cleanup_integration!
        
        success(message: "Successfully disconnected from #{provider.titleize}")
      rescue => e
        failure(errors: ["Failed to disconnect from #{provider.titleize}: #{e.message}"])
      end
    end

    private

    def find_integration!
      @integration = organization.accounting_integrations
                                 .find_by(provider: provider)
    end

    def revoke_tokens!
      case provider
      when 'quickbooks'
        revoke_quickbooks_tokens!
      when 'xero'
        revoke_xero_tokens!
      end
    end

    def revoke_quickbooks_tokens!
      # This would call QuickBooks API to revoke tokens
      # POST to https://developer.api.intuit.com/v2/oauth2/revoke
      # with the refresh_token
      Rails.logger.info "Revoking QuickBooks tokens for integration #{@integration.id}"
      
      # Simulate API call
      # HTTParty.post("#{QUICKBOOKS_BASE_URL}/oauth2/revoke", {
      #   body: { 
      #     token: @integration.refresh_token,
      #     token_type_hint: 'refresh_token'
      #   },
      #   headers: {
      #     'Authorization' => "Basic #{quickbooks_credentials}",
      #     'Content-Type' => 'application/x-www-form-urlencoded'
      #   }
      # })
    end

    def revoke_xero_tokens!
      # This would call Xero API to revoke tokens
      # POST to https://identity.xero.com/connect/revocation
      Rails.logger.info "Revoking Xero tokens for integration #{@integration.id}"
      
      # Simulate API call  
      # HTTParty.post("#{XERO_BASE_URL}/connect/revocation", {
      #   body: { 
      #     token: @integration.refresh_token,
      #     token_type_hint: 'refresh_token'
      #   },
      #   headers: {
      #     'Authorization' => "Basic #{xero_credentials}",
      #     'Content-Type' => 'application/x-www-form-urlencoded'
      #   }
      # })
    end

    def cleanup_integration!
      # Clear all tokens and mark as disconnected
      @integration.mark_disconnected!
      
      # Optionally clean up any pending syncs
      @integration.accounting_syncs.pending.update_all(
        status: 'failed',
        error_message: 'Integration disconnected',
        error_at: Time.current
      )
    end
  end
end