module FoodBeverage
  class SplitTabService < ApplicationService
    attr_accessor :organization, :user, :source_tab_id, :split_items, :new_golfer_names

    validates :organization, :user, :source_tab_id, presence: true
    validate :split_items_present
    validate :new_golfer_names_present
    validate :split_items_structure

    def call
      return validation_failure(self) unless valid?

      source_tab = find_source_tab
      return failure(['Source tab not found']) unless source_tab
      return failure(['Tab cannot be modified']) unless source_tab.can_be_modified?

      authorize_org_access!(user, organization)

      ActiveRecord::Base.transaction do
        new_tabs = create_new_tabs(source_tab)
        move_items_to_new_tabs(source_tab, new_tabs)
        update_all_tab_totals([source_tab] + new_tabs)
        
        # Broadcast real-time notification
        broadcast_tab_split(source_tab, new_tabs)

        success(
          source_tab: source_tab,
          new_tabs: new_tabs,
          total_new_tabs: new_tabs.length
        )
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    rescue StandardError => e
      failure(["Failed to split tab: #{e.message}"])
    end

    private

    def split_items_present
      if split_items.blank? || split_items.empty?
        errors.add(:split_items, 'must be provided')
      end
    end

    def new_golfer_names_present
      if new_golfer_names.blank? || new_golfer_names.empty?
        errors.add(:new_golfer_names, 'must be provided')
      end
    end

    def split_items_structure
      return unless split_items.present?

      split_items.each_with_index do |split, index|
        unless split.is_a?(Hash) && split[:golfer_name].present? && split[:item_ids].present?
          errors.add(:split_items, "Invalid structure at index #{index}")
          break
        end
      end
    end

    def find_source_tab
      organization.fnb_tabs.find_by(id: source_tab_id)
    end

    def create_new_tabs(source_tab)
      new_golfer_names.map do |golfer_name|
        FnbTab.create!(
          organization: organization,
          course: source_tab.course,
          user: user, # Current user becomes the server for new tabs
          golfer_name: golfer_name.strip,
          status: 'open',
          total_cents: 0,
          opened_at: Time.current
        )
      end
    end

    def move_items_to_new_tabs(source_tab, new_tabs)
      split_items.each do |split|
        golfer_name = split[:golfer_name]
        item_ids = split[:item_ids]
        
        target_tab = new_tabs.find { |tab| tab.golfer_name == golfer_name }
        next unless target_tab

        items_to_move = source_tab.fnb_tab_items.where(id: item_ids)
        
        items_to_move.each do |item|
          # Create duplicate item on new tab
          FnbTabItem.create!(
            fnb_tab: target_tab,
            added_by: item.added_by,
            name: item.name,
            quantity: item.quantity,
            unit_price_cents: item.unit_price_cents,
            category: item.category,
            notes: build_split_notes(item, source_tab)
          )
          
          # Remove from source tab
          item.destroy!
        end
      end
    end

    def update_all_tab_totals(tabs)
      tabs.each do |tab|
        tab.send(:calculate_total_cents)
        tab.save! if tab.changed?
      end
    end

    def build_split_notes(item, source_tab)
      base_notes = item.notes.present? ? item.notes : ''
      split_info = "Split from #{source_tab.golfer_name}'s tab at #{Time.current.strftime('%H:%M')}"
      
      [base_notes, split_info].reject(&:blank?).join(' | ')
    end

    def broadcast_tab_split(source_tab, new_tabs)
      ActionCable.server.broadcast(
        "fnb_tabs_#{organization.id}",
        {
          type: 'tab.split',
          source_tab: {
            id: source_tab.id,
            golfer_name: source_tab.golfer_name,
            total_cents: source_tab.total_cents,
            item_count: source_tab.item_count
          },
          new_tabs: new_tabs.map do |tab|
            {
              id: tab.id,
              golfer_name: tab.golfer_name,
              total_cents: tab.total_cents,
              item_count: tab.item_count
            }
          end,
          timestamp: Time.current.iso8601
        }
      )
    end
  end
end
