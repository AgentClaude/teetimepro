class MarketplaceSyncJob < ApplicationJob
  queue_as :default

  def perform(connection_id = nil)
    if connection_id
      # Sync a specific connection
      connection = MarketplaceConnection.find_by(id: connection_id)
      return unless connection&.active?

      sync_connection(connection)
    else
      # Sync all active connections
      MarketplaceConnection.syncable.find_each do |connection|
        sync_connection(connection)
      end
    end
  end

  private

  def sync_connection(connection)
    # First syndicate new tee times
    Marketplace::SyndicateTeeTimesService.call(connection: connection)

    # Then sync availability for existing listings
    Marketplace::SyncAvailabilityService.call(connection: connection)
  rescue StandardError => e
    Rails.logger.error("MarketplaceSyncJob failed for connection #{connection.id}: #{e.message}")
    connection.record_error!(e.message)
  end
end
