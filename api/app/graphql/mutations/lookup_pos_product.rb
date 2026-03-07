module Mutations
  class LookupPosProduct < BaseMutation
    argument :code, String, required: true, description: 'Barcode or SKU to look up'

    field :product, Types::PosProductType
    field :errors, [String], null: false

    def resolve(code:)
      result = Pos::LookupProductService.call(
        organization: current_organization,
        code: code
      )

      if result.success?
        { product: result.data[:product], errors: [] }
      else
        { product: nil, errors: result.errors }
      end
    end
  end
end
