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
    argument :stock_quantity, Integer, required: false

    field :product, Types::PosProductType
    field :errors, [String], null: false

    def resolve(id:, **args)
      result = Pos::UpdateProductService.call(
        organization: current_organization,
        user: current_user,
        product_id: id,
        **args
      )

      if result.success?
        { product: result.data[:product], errors: [] }
      else
        { product: nil, errors: result.errors }
      end
    end
  end
end
