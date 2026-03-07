module Pos
  # Creates a tab with items from product lookups in one go (quick sale flow).
  # Accepts an array of {product_id, quantity} items.
  class QuickSaleService < ApplicationService
    attr_accessor :organization, :user, :course, :golfer_name, :items

    validates :organization, :user, :course, :golfer_name, presence: true
    validate :items_present
    validate :all_products_valid

    def call
      return validation_failure(self) unless valid?

      authorize_org_access!(user, organization)

      ActiveRecord::Base.transaction do
        tab = create_tab
        tab_items = create_tab_items(tab)
        decrement_inventory(tab_items)

        tab.reload

        success(tab: tab, items: tab_items)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    rescue StandardError => e
      failure(["Quick sale failed: #{e.message}"])
    end

    private

    def items_present
      errors.add(:items, 'must contain at least one item') if items.blank? || items.empty?
    end

    def all_products_valid
      return if items.blank?

      items.each_with_index do |item, idx|
        product = organization.pos_products.find_by(id: item[:product_id])
        unless product
          errors.add(:items, "item #{idx + 1}: product not found")
          next
        end
        errors.add(:items, "item #{idx + 1}: #{product.name} is inactive") unless product.active?
        errors.add(:items, "item #{idx + 1}: #{product.name} is out of stock") unless product.in_stock?
      end
    end

    def create_tab
      FnbTab.create!(
        organization: organization,
        course: course,
        user: user,
        golfer_name: golfer_name,
        status: 'open',
        total_cents: 0,
        opened_at: Time.current
      )
    end

    def create_tab_items(tab)
      items.map do |item|
        product = organization.pos_products.find(item[:product_id])
        quantity = item[:quantity] || 1

        FnbTabItem.create!(
          fnb_tab: tab,
          added_by: user,
          name: product.name,
          quantity: quantity,
          unit_price_cents: product.price_cents,
          category: map_category(product.category),
          notes: "POS: #{product.sku}"
        )
      end
    end

    def decrement_inventory(tab_items)
      tab_items.each_with_index do |tab_item, idx|
        product = organization.pos_products.find(items[idx][:product_id])
        product.decrement_stock!(tab_item.quantity) if product.track_inventory?
      end
    end

    def map_category(product_category)
      case product_category
      when 'food' then 'food'
      when 'beverage' then 'beverage'
      else 'other'
      end
    end
  end
end
