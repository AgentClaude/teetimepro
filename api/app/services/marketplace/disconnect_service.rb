module Marketplace
  class DisconnectService < ApplicationService
    attr_accessor :organization, :connection_id

    validates :organization, :connection_id, presence: true

    def call
      return validation_failure(self) unless valid?

      connection = MarketplaceConnection.for_organization(organization)
                                        .find_by(id: connection_id)

      return failure(["Marketplace connection not found"]) unless connection

      # Remove all active listings from the marketplace
      active_listings = connection.marketplace_listings.active_listings

      if active_listings.any?
        begin
          adapter = Marketplace::AdapterFactory.for(connection)
          adapter.remove_listings(active_listings.pluck(:external_listing_id).compact)
        rescue StandardError => e
          Rails.logger.warn("Failed to remove listings from #{connection.provider}: #{e.message}")
        end

        active_listings.update_all(status: :cancelled)
      end

      connection.destroy!

      success(provider: connection.provider, listings_removed: active_listings.size)
    rescue ActiveRecord::RecordNotFound
      failure(["Marketplace connection not found"])
    end
  end
end
