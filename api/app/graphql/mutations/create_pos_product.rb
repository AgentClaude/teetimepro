module Mutations
  class CreatePosProduct < BaseMutation
    argument :name, String, required: true
    argument :sku, String, required: true
    argument :barcode, String, required: false
    argument :price_cents, Integer, required: true
    argument :category, String, required: false
    argument :description, String, required: false
    argument :track_inventory, Boolean, required: false
    argument :stock_quantity, Integer, required: false

    field :product, Types::PosProductType
    field :errors, [String], null: false

    def resolve(**args)
      result = Pos::CreateProductService.call(
        organization: current_organization,
        user: current_user,
        course: current_course,
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
