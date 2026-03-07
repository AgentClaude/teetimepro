module Mutations
  class ReceiveStock < BaseMutation
    argument :product_id, ID, required: true
    argument :course_id, ID, required: false
    argument :quantity, Integer, required: true
    argument :unit_cost_cents, Integer, required: true
    argument :notes, String, required: false
    argument :reference_type, String, required: false
    argument :reference_id, String, required: false

    field :inventory_movement, Types::InventoryMovementType
    field :inventory_level, Types::InventoryLevelType
    field :total_value_received_cents, Integer
    field :errors, [String], null: false

    def resolve(product_id:, quantity:, unit_cost_cents:, course_id: nil, notes: nil, reference_type: nil, reference_id: nil)
      product = current_organization.pos_products.find(product_id)
      course = course_id ? current_organization.courses.find(course_id) : current_course
      
      # Build reference object if provided
      reference = nil
      if reference_type && reference_id
        reference_class = reference_type.constantize
        reference = reference_class.find(reference_id) if reference_class
      end
      
      result = Inventory::ReceiveStockService.call(
        product: product,
        course: course,
        quantity: quantity,
        unit_cost_cents: unit_cost_cents,
        notes: notes,
        reference: reference,
        performed_by: current_user
      )

      if result.success?
        { 
          inventory_movement: result.movement,
          inventory_level: result.inventory_level,
          total_value_received_cents: result.total_value_received&.cents,
          errors: [] 
        }
      else
        { 
          inventory_movement: nil, 
          inventory_level: nil, 
          total_value_received_cents: nil,
          errors: result.errors 
        }
      end
    rescue NameError => e
      { 
        inventory_movement: nil, 
        inventory_level: nil, 
        total_value_received_cents: nil,
        errors: ["Invalid reference type: #{reference_type}"] 
      }
    end
  end
end