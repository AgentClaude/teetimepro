module Products
  class CreateProductService < ApplicationService
    attr_accessor :organization, :course, :name, :sku, :barcode, :price_cents, 
                  :category, :description, :track_inventory, :reorder_point, 
                  :reorder_quantity, :initial_stock, :performed_by

    validates :organization, presence: true
    validates :course, presence: true
    validates :name, presence: true
    validates :sku, presence: true
    validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :category, presence: true, inclusion: { in: PosProduct.categories.keys }
    validates :performed_by, presence: true
    validates :reorder_point, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :reorder_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :initial_stock, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    def call
      return failure(errors.full_messages) unless valid?
      
      authorize_org_access!(performed_by, organization)
      
      ActiveRecord::Base.transaction do
        product = create_product
        return validation_failure(product) unless product.persisted?
        
        # Create inventory level if tracking inventory
        inventory_level = create_inventory_level(product) if track_inventory
        
        # Create initial stock movement if specified
        initial_movement = create_initial_stock_movement(product) if initial_stock && initial_stock > 0
        
        success(
          product: product,
          inventory_level: inventory_level,
          initial_movement: initial_movement
        )
      end
    rescue StandardError => e
      failure([e.message])
    end

    private

    def create_product
      PosProduct.create!(
        organization: organization,
        course: course,
        name: name,
        sku: sku,
        barcode: barcode,
        price_cents: price_cents,
        category: category,
        description: description,
        track_inventory: track_inventory || false,
        active: true
      )
    end

    def create_inventory_level(product)
      InventoryLevel.create!(
        organization: organization,
        pos_product: product,
        course: course,
        current_stock: 0,
        reorder_point: reorder_point || 0,
        reorder_quantity: reorder_quantity || 0
      )
    end

    def create_initial_stock_movement(product)
      return nil unless initial_stock && initial_stock > 0

      InventoryMovement.create!(
        organization: organization,
        pos_product: product,
        course: course,
        movement_type: 'adjustment',
        quantity: initial_stock,
        notes: 'Initial stock setup',
        performed_by: performed_by
      )
    end
  end
end