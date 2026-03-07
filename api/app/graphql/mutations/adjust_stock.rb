module Mutations
  class AdjustStock < BaseMutation
    argument :product_id, ID, required: true
    argument :course_id, ID, required: false
    argument :quantity, Integer, required: true
    argument :notes, String, required: false
    argument :unit_cost_cents, Integer, required: false

    field :inventory_movement, Types::InventoryMovementType
    field :inventory_level, Types::InventoryLevelType
    field :errors, [String], null: false

    def resolve(product_id:, quantity:, course_id: nil, notes: nil, unit_cost_cents: nil)
      product = current_organization.pos_products.find(product_id)
      course = course_id ? current_organization.courses.find(course_id) : current_course
      
      result = Inventory::AdjustStockService.call(
        product: product,
        course: course,
        quantity: quantity,
        notes: notes,
        unit_cost_cents: unit_cost_cents,
        performed_by: current_user
      )

      if result.success?
        { 
          inventory_movement: result.movement,
          inventory_level: result.inventory_level,
          errors: [] 
        }
      else
        { 
          inventory_movement: nil, 
          inventory_level: nil, 
          errors: result.errors 
        }
      end
    end
  end
end