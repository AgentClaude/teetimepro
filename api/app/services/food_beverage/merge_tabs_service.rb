module FoodBeverage
  class MergeTabsService < ApplicationService
    attr_accessor :organization, :user, :source_tab_ids, :target_tab_id

    validates :organization, :user, :target_tab_id, presence: true
    validate :source_tab_ids_present
    validate :tabs_are_different

    def call
      return validation_failure(self) unless valid?

      target_tab = find_target_tab
      return failure(['Target tab not found']) unless target_tab
      return failure(['Target tab cannot be modified']) unless target_tab.can_be_modified?

      source_tabs = find_source_tabs
      return failure(['One or more source tabs not found']) if source_tabs.length != source_tab_ids.length
      
      invalid_sources = source_tabs.reject(&:can_be_modified?)
      return failure(['One or more source tabs cannot be modified']) if invalid_sources.any?

      authorize_org_access!(user, organization)

      ActiveRecord::Base.transaction do
        merged_data = perform_merge(target_tab, source_tabs)
        
        # Mark source tabs as merged
        source_tabs.each(&:merge!)
        
        # Recalculate target tab total
        target_tab.send(:calculate_total_cents)
        target_tab.save!

        # Broadcast real-time notification
        broadcast_tabs_merged(target_tab, source_tabs, merged_data)

        success(
          target_tab: target_tab,
          merged_tabs: source_tabs,
          items_merged: merged_data[:items_count],
          total_amount_merged: merged_data[:total_amount]
        )
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    rescue StandardError => e
      failure(["Failed to merge tabs: #{e.message}"])
    end

    private

    def source_tab_ids_present
      if source_tab_ids.blank? || source_tab_ids.empty?
        errors.add(:source_tab_ids, 'must be provided')
      end
    end

    def tabs_are_different
      if source_tab_ids.include?(target_tab_id.to_s)
        errors.add(:target_tab_id, 'cannot be the same as source tabs')
      end
    end

    def find_target_tab
      organization.fnb_tabs.find_by(id: target_tab_id)
    end

    def find_source_tabs
      organization.fnb_tabs.where(id: source_tab_ids)
    end

    def perform_merge(target_tab, source_tabs)
      items_count = 0
      total_amount = 0

      source_tabs.each do |source_tab|
        source_tab.fnb_tab_items.each do |item|
          # Create new item on target tab
          FnbTabItem.create!(
            fnb_tab: target_tab,
            added_by: item.added_by,
            name: "#{item.name} (merged from #{source_tab.golfer_name})",
            quantity: item.quantity,
            unit_price_cents: item.unit_price_cents,
            category: item.category,
            notes: build_merge_notes(item, source_tab)
          )
          
          items_count += 1
          total_amount += item.total_cents
        end
      end

      { items_count: items_count, total_amount: total_amount }
    end

    def build_merge_notes(item, source_tab)
      base_notes = item.notes.present? ? item.notes : ''
      merge_info = "Merged from #{source_tab.golfer_name}'s tab at #{Time.current.strftime('%H:%M')}"
      
      [base_notes, merge_info].reject(&:blank?).join(' | ')
    end

    def broadcast_tabs_merged(target_tab, source_tabs, merged_data)
      ActionCable.server.broadcast(
        "fnb_tabs_#{organization.id}",
        {
          type: 'tabs.merged',
          target_tab: {
            id: target_tab.id,
            golfer_name: target_tab.golfer_name,
            total_cents: target_tab.total_cents,
            item_count: target_tab.item_count
          },
          source_tabs: source_tabs.map do |tab|
            {
              id: tab.id,
              golfer_name: tab.golfer_name,
              total_cents: tab.total_cents
            }
          end,
          merged_data: merged_data,
          timestamp: Time.current.iso8601
        }
      )
    end
  end
end
