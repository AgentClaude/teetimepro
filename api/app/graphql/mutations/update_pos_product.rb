module Mutations
  class UpdatePosProduct < BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: false
    argument :sku, String, required: false
    argument :barcode, String, required: false
    argument :price_cents, Integer, required: false
    argument :category, String, required: false
    argument :description, String, required: false
    argument :active, Boolean, required: false
    argument :track_inventory, Boolean, required: false
    argument :reorder_point, Integer, required: false
    argument :reorder_quantity, Integer, required: false

    field :product, Types::PosProductType
    field :inventory_levels, [Types::InventoryLevelType], null: false
    field :errors, [String], null: false

    def resolve(id:, **args)
      product = current_organization.pos_products.find(id)
      
      result = Products::UpdateProductService.call(
        product: product,
        performed_by: current_user,
        **args
      )

      if result.success?
        { 
          product: result.product, 
          inventory_levels: result.inventory_levels,
          errors: [] 
        }
      else
        { product: nil, inventory_levels: [], errors: result.errors }
      end
    end
  end
end
