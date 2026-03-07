module Inventory
  class ReceiveStockService < ApplicationService
    attr_accessor :product, :course, :quantity, :unit_cost_cents, :notes, :performed_by, :reference

    validates :product, presence: true
    validates :course, presence: true
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :unit_cost_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :performed_by, presence: true

    def call
      return failure(errors.full_messages) unless valid?
      
      authorize_org_access!(performed_by, product.organization)
      
      ActiveRecord::Base.transaction do
        movement = create_movement
        return validation_failure(movement) unless movement.persisted?
        
        update_product_costs
        
        success(
          movement: movement, 
          inventory_level: movement.pos_product.inventory_levels.find_by(course: course),
          total_value_received: movement.total_cost_amount
        )
      end
    rescue StandardError => e
      failure([e.message])
    end

    private

    def create_movement
      total_cost = unit_cost_cents * quantity
      
      InventoryMovement.create!(
        organization: product.organization,
        pos_product: product,
        course: course,
        movement_type: 'receipt',
        quantity: quantity,
        unit_cost_cents: unit_cost_cents,
        total_cost_cents: total_cost,
        notes: notes || "Stock receipt",
        performed_by: performed_by,
        reference: reference
      )
    end

    def update_product_costs
      # Update the product's price if this is significantly different from current
      # This is optional business logic - you might want to update the product's cost basis
      current_price_cents = product.price_cents
      
      # If the received cost is more than 20% different from current price, 
      # consider updating (this is just an example business rule)
      cost_difference_percent = ((unit_cost_cents - current_price_cents).abs.to_f / current_price_cents) * 100
      
      if cost_difference_percent > 20 && notes&.include?('update_price')
        product.update(price_cents: unit_cost_cents)
      end
    end
  end
end