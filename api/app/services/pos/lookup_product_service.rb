module Pos
  class LookupProductService < ApplicationService
    attr_accessor :organization, :code

    validates :organization, :code, presence: true

    def call
      return validation_failure(self) unless valid?

      product = find_product
      return failure(['Product not found']) unless product
      return failure(['Product is inactive']) unless product.active?
      return failure(['Product is out of stock']) unless product.in_stock?

      success(product: product)
    end

    private

    def find_product
      normalized = code.strip

      # Try barcode first (exact match), then SKU
      organization.pos_products.active.find_by(barcode: normalized) ||
        organization.pos_products.active.find_by(sku: normalized)
    end
  end
end
