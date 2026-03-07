module Calendars
  class GoogleAuthService < ApplicationService
    require 'google/apis/calendar_v3'

    attr_accessor :user, :authorization_code

    validates :user, :authorization_code, presence: true

    GOOGLE_CLIENT_ID = Rails.application.credentials.google&.client_id
    GOOGLE_CLIENT_SECRET = Rails.application.credentials.google&.client_secret
    REDIRECT_URI = "https://app.teetimespro.com/auth/google/callback"
    SCOPE = ["https://www.googleapis.com/auth/calendar"]

    def call
      return validation_failure(self) unless valid?
      return failure(["Google credentials not configured"]) unless credentials_present?

      begin
        # Exchange authorization code for tokens
        tokens = exchange_code_for_tokens

        # Get calendar list to find primary calendar
        calendar_info = fetch_primary_calendar(tokens[:access_token])

        # Create or update calendar connection
        connection = user.calendar_connections.find_or_initialize_by(provider: 'google')
        connection.assign_attributes(
          access_token: tokens[:access_token],
          refresh_token: tokens[:refresh_token],
          token_expires_at: tokens[:expires_at],
          enabled: true,
          calendar_id: calendar_info[:id],
          calendar_name: calendar_info[:name]
        )

        if connection.save
          success(
            connection: connection,
            calendar_name: calendar_info[:name]
          )
        else
          validation_failure(connection)
        end
      rescue Google::Apis::Error => e
        Rails.logger.error "Google API error: #{e.message}"
        failure(["Google Calendar authorization failed: #{e.message}"])
      rescue => e
        Rails.logger.error "Calendar auth error: #{e.message}"
        failure(["Calendar authorization failed: #{e.message}"])
      end
    end

    private

    def credentials_present?
      GOOGLE_CLIENT_ID.present? && GOOGLE_CLIENT_SECRET.present?
    end

    def exchange_code_for_tokens
      uri = URI('https://oauth2.googleapis.com/token')
      
      params = {
        code: authorization_code,
        client_id: GOOGLE_CLIENT_ID,
        client_secret: GOOGLE_CLIENT_SECRET,
        redirect_uri: REDIRECT_URI,
        grant_type: 'authorization_code'
      }

      response = Net::HTTP.post_form(uri, params)
      
      unless response.is_a?(Net::HTTPSuccess)
        raise "Token exchange failed: #{response.body}"
      end

      token_data = JSON.parse(response.body)
      
      {
        access_token: token_data['access_token'],
        refresh_token: token_data['refresh_token'],
        expires_at: Time.current + token_data['expires_in'].seconds
      }
    end

    def fetch_primary_calendar(access_token)
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = access_token

      # Get calendar list
      calendar_list = service.list_calendar_lists

      # Find primary calendar
      primary_calendar = calendar_list.items.find { |cal| cal.primary }
      
      unless primary_calendar
        raise "No primary calendar found"
      end

      {
        id: primary_calendar.id,
        name: primary_calendar.summary || "Primary Calendar"
      }
    end

    def self.authorization_url(state = nil)
      params = {
        client_id: GOOGLE_CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        scope: SCOPE.join(' '),
        response_type: 'code',
        access_type: 'offline',
        prompt: 'consent'
      }
      
      params[:state] = state if state.present?

      uri = URI('https://accounts.google.com/o/oauth2/auth')
      uri.query = URI.encode_www_form(params)
      uri.to_s
    end
  end
end