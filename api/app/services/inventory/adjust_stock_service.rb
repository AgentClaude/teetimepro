module Inventory
  class AdjustStockService < ApplicationService
    attr_accessor :product, :course, :quantity, :notes, :performed_by, :unit_cost_cents

    validates :product, presence: true
    validates :course, presence: true
    validates :quantity, presence: true, numericality: { other_than: 0 }
    validates :performed_by, presence: true

    def call
      return failure(errors.full_messages) unless valid?
      
      authorize_org_access!(performed_by, product.organization)
      
      ActiveRecord::Base.transaction do
        movement = create_movement
        return validation_failure(movement) unless movement.persisted?
        
        success(movement: movement, inventory_level: movement.pos_product.inventory_levels.find_by(course: course))
      end
    rescue StandardError => e
      failure([e.message])
    end

    private

    def create_movement
      InventoryMovement.create!(
        organization: product.organization,
        pos_product: product,
        course: course,
        movement_type: 'adjustment',
        quantity: quantity,
        notes: notes || "Manual stock adjustment",
        performed_by: performed_by,
        unit_cost_cents: unit_cost_cents,
        total_cost_cents: unit_cost_cents ? (unit_cost_cents * quantity.abs) : nil
      )
    end
  end
end