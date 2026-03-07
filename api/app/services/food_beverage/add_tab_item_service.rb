module FoodBeverage
  class AddTabItemService < ApplicationService
    attr_accessor :organization, :user, :tab_id, :name, :quantity, :unit_price_cents, :category, :notes

    validates :organization, :user, :tab_id, :name, presence: true
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :unit_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :category, inclusion: { in: %w[food beverage other] }

    def call
      return validation_failure(self) unless valid?

      tab = find_tab
      return failure(['Tab not found']) unless tab
      return failure(['Tab cannot be modified']) unless tab.can_be_modified?

      authorize_org_access!(user, organization)

      ActiveRecord::Base.transaction do
        item = create_tab_item(tab)
        
        # The tab total will be automatically updated via the FnbTabItem after_create callback
        tab.reload

        # Broadcast real-time notification
        broadcast_item_added(tab, item)

        success(item: item, tab: tab)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    rescue StandardError => e
      failure(["Failed to add item: #{e.message}"])
    end

    private

    def find_tab
      organization.fnb_tabs.find_by(id: tab_id)
    end

    def create_tab_item(tab)
      FnbTabItem.create!(
        fnb_tab: tab,
        added_by: user,
        name: name.strip,
        quantity: quantity,
        unit_price_cents: unit_price_cents,
        category: category || 'food',
        notes: notes&.strip
      )
    end

    def broadcast_item_added(tab, item)
      ActionCable.server.broadcast(
        "fnb_tabs_#{organization.id}",
        {
          type: 'tab.item_added',
          tab: {
            id: tab.id,
            golfer_name: tab.golfer_name,
            total_cents: tab.total_cents,
            item_count: tab.item_count
          },
          item: {
            id: item.id,
            name: item.name,
            quantity: item.quantity,
            unit_price_cents: item.unit_price_cents,
            total_cents: item.total_cents,
            category: item.category,
            added_by_name: item.added_by.full_name
          },
          timestamp: Time.current.iso8601
        }
      )
    end
  end
end
