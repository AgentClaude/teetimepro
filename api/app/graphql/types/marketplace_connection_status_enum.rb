module Types
  class MarketplaceConnectionStatusEnum < Types::BaseEnum
    value "PENDING", "Connection pending validation", value: "pending"
    value "ACTIVE", "Connection active and syncing", value: "active"
    value "PAUSED", "Connection paused", value: "paused"
    value "ERROR", "Connection has an error", value: "error"
  end
end
