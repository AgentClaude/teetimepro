module FoodBeverage
  class RemoveTabItemService < ApplicationService
    attr_accessor :organization, :user, :tab_item_id

    validates :organization, :user, :tab_item_id, presence: true

    def call
      return validation_failure(self) unless valid?

      item = find_tab_item
      return failure(['Item not found']) unless item

      tab = item.fnb_tab
      return failure(['Tab cannot be modified']) unless tab.can_be_modified?

      authorize_org_access!(user, organization)

      ActiveRecord::Base.transaction do
        item_data = extract_item_data(item)
        
        item.destroy!
        
        # The tab total will be automatically updated via the FnbTabItem after_destroy callback
        tab.reload

        # Broadcast real-time notification
        broadcast_item_removed(tab, item_data)

        success(tab: tab, removed_item: item_data)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    rescue StandardError => e
      failure(["Failed to remove item: #{e.message}"])
    end

    private

    def find_tab_item
      FnbTabItem.joins(:fnb_tab)
               .where(fnb_tabs: { organization: organization })
               .find_by(id: tab_item_id)
    end

    def extract_item_data(item)
      {
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        unit_price_cents: item.unit_price_cents,
        total_cents: item.total_cents,
        category: item.category,
        added_by_name: item.added_by.full_name
      }
    end

    def broadcast_item_removed(tab, item_data)
      ActionCable.server.broadcast(
        "fnb_tabs_#{organization.id}",
        {
          type: 'tab.item_removed',
          tab: {
            id: tab.id,
            golfer_name: tab.golfer_name,
            total_cents: tab.total_cents,
            item_count: tab.item_count
          },
          removed_item: item_data,
          timestamp: Time.current.iso8601
        }
      )
    end
  end
end
