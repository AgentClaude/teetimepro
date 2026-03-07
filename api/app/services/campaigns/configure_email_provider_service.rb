# frozen_string_literal: true

module Campaigns
  class ConfigureEmailProviderService < ApplicationService
    attr_accessor :organization, :user, :provider_type, :api_key,
                  :from_email, :from_name, :is_default, :settings

    validates :organization, :user, :provider_type, :api_key, :from_email, presence: true

    def call
      return validation_failure(self) unless valid?

      authorize_org_access!(user, organization)
      authorize_role!(user, :manager)

      begin
        provider = find_or_initialize_provider
        update_provider_attributes(provider)

        if provider.save
          verification = provider.verify!
          success(
            provider: provider,
            verified: verification[:success],
            verification_message: verification[:error]
          )
        else
          validation_failure(provider)
        end
      rescue StandardError => e
        failure(["Failed to configure email provider: #{e.message}"])
      end
    end

    private

    def find_or_initialize_provider
      organization.email_providers.find_or_initialize_by(provider_type: provider_type)
    end

    def update_provider_attributes(provider)
      provider.assign_attributes(
        api_key: api_key,
        from_email: from_email,
        from_name: from_name,
        is_default: is_default.nil? ? !organization.email_providers.active.exists? : is_default,
        settings: settings || {},
        is_active: true
      )
    end
  end
end
