module Mutations
  class PosQuickSale < BaseMutation
    argument :golfer_name, String, required: true
    argument :items, [Types::PosSaleItemInput], required: true

    field :tab, Types::FnbTabType
    field :errors, [String], null: false

    def resolve(golfer_name:, items:)
      item_hashes = items.map { |i| { product_id: i.product_id, quantity: i.quantity } }

      result = Pos::QuickSaleService.call(
        organization: current_organization,
        user: current_user,
        course: current_course,
        golfer_name: golfer_name,
        items: item_hashes
      )

      if result.success?
        { tab: result.data[:tab], errors: [] }
      else
        { tab: nil, errors: result.errors }
      end
    end
  end
end
