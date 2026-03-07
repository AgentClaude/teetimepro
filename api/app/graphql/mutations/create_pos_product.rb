module Mutations
  class CreatePosProduct < BaseMutation
    argument :name, String, required: true
    argument :sku, String, required: true
    argument :barcode, String, required: false
    argument :price_cents, Integer, required: true
    argument :category, String, required: false
    argument :description, String, required: false
    argument :track_inventory, Boolean, required: false
    argument :reorder_point, Integer, required: false
    argument :reorder_quantity, Integer, required: false
    argument :initial_stock, Integer, required: false

    field :product, Types::PosProductType
    field :inventory_level, Types::InventoryLevelType
    field :errors, [String], null: false

    def resolve(**args)
      result = Products::CreateProductService.call(
        organization: current_organization,
        course: current_course,
        performed_by: current_user,
        **args
      )

      if result.success?
        { 
          product: result.product, 
          inventory_level: result.inventory_level,
          errors: [] 
        }
      else
        { product: nil, inventory_level: nil, errors: result.errors }
      end
    end
  end
end
