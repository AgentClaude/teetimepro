module Mutations
  class CreateTurnOrder < BaseMutation
    argument :booking_id, ID, required: true
    argument :items, [Types::PosSaleItemInput], required: true
    argument :delivery_hole, Integer, required: false, default_value: 10,
             description: 'Hole where food should be delivered (default: 10 — the turn)'
    argument :delivery_notes, String, required: false,
             description: 'Special instructions for the order'

    field :tab, Types::FnbTabType
    field :errors, [String], null: false

    def resolve(booking_id:, items:, delivery_hole:, delivery_notes: nil)
      item_hashes = items.map { |i| { product_id: i.product_id, quantity: i.quantity } }

      result = TeeSheets::CreateTurnOrderService.call(
        organization: current_organization,
        user: current_user,
        course: current_course,
        booking_id: booking_id,
        items: item_hashes,
        delivery_hole: delivery_hole,
        delivery_notes: delivery_notes
      )

      if result.success?
        { tab: result.data[:tab], errors: [] }
      else
        { tab: nil, errors: result.errors }
      end
    end
  end
end
