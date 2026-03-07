module Pos
  class UpdateProductService < ApplicationService
    attr_accessor :organization, :user, :product_id, :name, :sku, :barcode,
                  :price_cents, :category, :description, :active, :track_inventory, :stock_quantity

    validates :organization, :user, :product_id, presence: true

    def call
      return validation_failure(self) unless valid?

      authorize_org_access!(user, organization)
      authorize_role!(user, :manager)

      product = organization.pos_products.find_by(id: product_id)
      return failure(['Product not found']) unless product

      attrs = build_attributes
      if product.update(attrs)
        success(product: product)
      else
        failure(product.errors.full_messages)
      end
    end

    private

    def build_attributes
      {}.tap do |attrs|
        attrs[:name] = name.strip if name.present?
        attrs[:sku] = sku.strip if sku.present?
        attrs[:barcode] = barcode&.strip if barcode
        attrs[:price_cents] = price_cents if price_cents
        attrs[:category] = category if category
        attrs[:description] = description&.strip if description
        attrs[:active] = active unless active.nil?
        attrs[:track_inventory] = track_inventory unless track_inventory.nil?
        attrs[:stock_quantity] = stock_quantity if stock_quantity
      end
    end
  end
end
