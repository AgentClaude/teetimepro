module Types
  class PosProductType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :sku, String, null: false
    field :barcode, String
    field :price_cents, Integer, null: false
    field :category, String, null: false
    field :description, String
    field :active, Boolean, null: false
    field :track_inventory, Boolean, null: false
    field :stock_quantity, Integer
    field :in_stock, Boolean, null: false
    field :formatted_price, String, null: false
    field :inventory_levels, [Types::InventoryLevelType], null: false
    field :inventory_movements, [Types::InventoryMovementType], null: false
    field :needs_reorder, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def needs_reorder
      object.needs_reorder?
    end

    def inventory_movements
      # Limit to recent movements to avoid loading too much data
      object.inventory_movements.recent.limit(50)
    end
  end
end
