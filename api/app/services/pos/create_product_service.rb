module Pos
  class CreateProductService < ApplicationService
    attr_accessor :organization, :user, :course, :name, :sku, :barcode,
                  :price_cents, :category, :description, :track_inventory, :stock_quantity

    validates :organization, :user, :course, :name, :sku, :price_cents, presence: true
    validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
    validates :category, inclusion: { in: %w[food beverage apparel equipment rental other] }, allow_nil: true

    def call
      return validation_failure(self) unless valid?

      authorize_org_access!(user, organization)
      authorize_role!(user, :manager)

      product = PosProduct.new(
        organization: organization,
        course: course,
        name: name.strip,
        sku: sku.strip,
        barcode: barcode&.strip.presence,
        price_cents: price_cents,
        category: category || 'other',
        description: description&.strip,
        track_inventory: track_inventory || false,
        stock_quantity: stock_quantity
      )

      if product.save
        success(product: product)
      else
        failure(product.errors.full_messages)
      end
    end
  end
end
