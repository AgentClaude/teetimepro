module Marketplace
  class UpdateSettingsService < ApplicationService
    attr_accessor :organization, :connection_id, :settings, :status

    validates :organization, :connection_id, presence: true

    ALLOWED_SETTINGS = %w[
      auto_syndicate
      min_advance_hours
      max_advance_days
      discount_percent
      blocked_time_ranges
      min_available_spots
    ].freeze

    def call
      return validation_failure(self) unless valid?

      connection = MarketplaceConnection.for_organization(organization)
                                        .find_by(id: connection_id)

      return failure(["Marketplace connection not found"]) unless connection

      updates = {}

      if settings.present?
        sanitized = settings.slice(*ALLOWED_SETTINGS)
        updates[:settings] = connection.settings.merge(sanitized)
      end

      if status.present?
        return failure(["Invalid status"]) unless %w[active paused].include?(status)
        updates[:status] = status
      end

      return failure(["No updates provided"]) if updates.empty?

      connection.update!(updates)

      success(connection: connection)
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end
  end
end
