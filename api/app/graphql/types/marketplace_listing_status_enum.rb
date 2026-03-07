module Types
  class MarketplaceListingStatusEnum < Types::BaseEnum
    value "PENDING", "Listing pending", value: "pending"
    value "LISTED", "Listed on marketplace", value: "listed"
    value "BOOKED", "Booked via marketplace", value: "booked"
    value "EXPIRED", "Listing expired", value: "expired"
    value "ERROR", "Listing error", value: "error"
    value "CANCELLED", "Listing cancelled", value: "cancelled"
  end
end
