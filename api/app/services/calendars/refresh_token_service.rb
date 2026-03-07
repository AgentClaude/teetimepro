module Calendars
  class RefreshTokenService < ApplicationService
    attr_accessor :connection

    validates :connection, presence: true

    GOOGLE_CLIENT_ID = Rails.application.credentials.google&.client_id
    GOOGLE_CLIENT_SECRET = Rails.application.credentials.google&.client_secret

    def call
      return validation_failure(self) unless valid?
      return failure(["Connection is not a Google connection"]) unless connection.google?
      return failure(["No refresh token available"]) unless connection.refresh_token.present?
      return failure(["Google credentials not configured"]) unless credentials_present?

      begin
        # Request new access token using refresh token
        new_tokens = refresh_access_token

        # Update the connection with new token info
        connection.update!(
          access_token: new_tokens[:access_token],
          token_expires_at: new_tokens[:expires_at],
          refresh_token: new_tokens[:refresh_token] || connection.refresh_token
        )

        success(
          connection: connection,
          message: "Token refreshed successfully"
        )
      rescue => e
        Rails.logger.error "Token refresh error: #{e.message}"
        
        # Disable the connection if refresh fails
        connection.update!(enabled: false)
        
        failure([
          "Failed to refresh Google Calendar token. Please reconnect your calendar.",
          e.message
        ])
      end
    end

    private

    def credentials_present?
      GOOGLE_CLIENT_ID.present? && GOOGLE_CLIENT_SECRET.present?
    end

    def refresh_access_token
      uri = URI('https://oauth2.googleapis.com/token')
      
      params = {
        client_id: GOOGLE_CLIENT_ID,
        client_secret: GOOGLE_CLIENT_SECRET,
        refresh_token: connection.refresh_token,
        grant_type: 'refresh_token'
      }

      response = Net::HTTP.post_form(uri, params)
      
      unless response.is_a?(Net::HTTPSuccess)
        error_data = JSON.parse(response.body) rescue {}
        error_message = error_data['error_description'] || error_data['error'] || 'Unknown error'
        raise "Token refresh failed: #{error_message}"
      end

      token_data = JSON.parse(response.body)
      
      # Google sometimes returns a new refresh token
      refresh_token = token_data['refresh_token'] || connection.refresh_token
      
      {
        access_token: token_data['access_token'],
        refresh_token: refresh_token,
        expires_at: Time.current + token_data['expires_in'].seconds
      }
    end
  end
end