module Marketplace
  class ConnectService < ApplicationService
    attr_accessor :organization, :course, :provider, :credentials, :settings

    validates :organization, :course, :provider, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Invalid marketplace provider"]) unless valid_provider?
      return failure(["Course does not belong to this organization"]) unless course_belongs_to_org?

      connection = MarketplaceConnection.new(
        organization: organization,
        course: course,
        provider: provider,
        credentials: credentials || {},
        settings: settings || {},
        status: :pending
      )

      unless connection.save
        return validation_failure(connection)
      end

      # Validate credentials with the marketplace
      validation_result = validate_marketplace_credentials(connection)

      if validation_result[:valid]
        connection.update!(
          status: :active,
          external_course_id: validation_result[:external_course_id]
        )
      else
        connection.update!(
          status: :error,
          last_error: validation_result[:error]
        )
      end

      success(connection: connection)
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end

    private

    def valid_provider?
      MarketplaceConnection::PROVIDERS.include?(provider)
    end

    def course_belongs_to_org?
      course.organization_id == organization.id
    end

    def validate_marketplace_credentials(connection)
      adapter = marketplace_adapter(connection)
      adapter.validate_connection
    rescue StandardError => e
      { valid: false, error: "Connection validation failed: #{e.message}" }
    end

    def marketplace_adapter(connection)
      Marketplace::AdapterFactory.for(connection)
    end
  end
end
