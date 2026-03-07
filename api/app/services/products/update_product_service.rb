module Products
  class UpdateProductService < ApplicationService
    attr_accessor :product, :name, :sku, :barcode, :price_cents, :category, 
                  :description, :track_inventory, :active, :reorder_point, 
                  :reorder_quantity, :performed_by

    validates :product, presence: true
    validates :performed_by, presence: true
    validates :price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :category, inclusion: { in: PosProduct.categories.keys }, allow_nil: true
    validates :reorder_point, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :reorder_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    def call
      return failure(errors.full_messages) unless valid?
      
      authorize_org_access!(performed_by, product.organization)
      
      ActiveRecord::Base.transaction do
        old_track_inventory = product.track_inventory
        
        update_product
        return validation_failure(product) unless product.errors.empty?
        
        # Handle inventory tracking changes
        handle_inventory_tracking_changes(old_track_inventory)
        
        # Update inventory levels if reorder settings changed
        update_inventory_levels if reorder_settings_changed?
        
        success(
          product: product.reload,
          inventory_levels: product.inventory_levels,
          tracking_changed: old_track_inventory != product.track_inventory
        )
      end
    rescue StandardError => e
      failure([e.message])
    end

    private

    def update_product
      update_attributes = build_update_attributes
      product.update!(update_attributes)
    end

    def build_update_attributes
      attributes = {}
      
      attributes[:name] = name if name.present?
      attributes[:sku] = sku if sku.present?
      attributes[:barcode] = barcode if barcode.present?
      attributes[:price_cents] = price_cents if price_cents.present?
      attributes[:category] = category if category.present?
      attributes[:description] = description if description.present?
      attributes[:track_inventory] = track_inventory unless track_inventory.nil?
      attributes[:active] = active unless active.nil?
      
      attributes
    end

    def handle_inventory_tracking_changes(old_track_inventory)
      # If inventory tracking was just enabled, create inventory levels
      if !old_track_inventory && product.track_inventory
        create_inventory_levels_for_all_courses
      end
      
      # If inventory tracking was disabled, you might want to archive or clean up
      # inventory data, but we'll leave it for historical purposes
    end

    def create_inventory_levels_for_all_courses
      product.organization.courses.each do |course|
        next if product.inventory_levels.exists?(course: course)
        
        InventoryLevel.create!(
          organization: product.organization,
          pos_product: product,
          course: course,
          current_stock: 0,
          reorder_point: reorder_point || 0,
          reorder_quantity: reorder_quantity || 0
        )
      end
    end

    def update_inventory_levels
      return unless reorder_point.present? || reorder_quantity.present?
      
      product.inventory_levels.each do |level|
        update_attrs = {}
        update_attrs[:reorder_point] = reorder_point if reorder_point.present?
        update_attrs[:reorder_quantity] = reorder_quantity if reorder_quantity.present?
        
        level.update!(update_attrs) if update_attrs.any?
      end
    end

    def reorder_settings_changed?
      reorder_point.present? || reorder_quantity.present?
    end
  end
end