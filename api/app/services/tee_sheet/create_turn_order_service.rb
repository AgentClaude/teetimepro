module TeeSheet
  # Creates an F&B tab linked to a booking for food orders at the turn.
  # Golfers can pre-order food/drinks to be ready when they finish hole 9.
  class CreateTurnOrderService < ApplicationService
    attr_accessor :organization, :user, :course, :booking_id, :items,
                  :delivery_hole, :delivery_notes

    validates :organization, :user, :course, :booking_id, presence: true
    validate :items_present
    validate :booking_valid
    validate :no_existing_turn_order

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
      failure(["Turn order failed: #{e.message}"])
    end

    private

    def items_present
      errors.add(:items, 'must contain at least one item') if items.blank? || items.empty?
    end

    def booking_valid
      return if booking_id.blank?

      booking = find_booking
      unless booking
        errors.add(:booking, 'not found')
        return
      end

      unless booking.confirmed? || booking.checked_in?
        errors.add(:booking, 'must be confirmed or checked in')
      end
    end

    def no_existing_turn_order
      return if booking_id.blank?

      booking = find_booking
      return unless booking

      if booking.fnb_tabs.turn_orders.open_tabs.exists?
        errors.add(:booking, 'already has an open turn order')
      end
    end

    def find_booking
      @booking ||= Booking.joins(tee_time: { tee_sheet: :course })
                          .where(courses: { organization_id: organization.id })
                          .find_by(id: booking_id)
    end

    def create_tab
      booking = find_booking
      golfer_name = booking.booking_players.first&.name || booking.user.full_name

      FnbTab.create!(
        organization: organization,
        course: course,
        user: user,
        booking: booking,
        golfer_name: golfer_name,
        status: 'open',
        total_cents: 0,
        turn_order: true,
        delivery_hole: delivery_hole || 10,
        delivery_notes: delivery_notes&.strip,
        opened_at: Time.current
      )
    end

    def create_tab_items(tab)
      items.map do |item|
        product = organization.pos_products.active.find(item[:product_id])
        quantity = item[:quantity] || 1

        raise "#{product.name} is out of stock" unless product.in_stock?

        FnbTabItem.create!(
          fnb_tab: tab,
          added_by: user,
          name: product.name,
          quantity: quantity,
          unit_price_cents: product.price_cents,
          category: map_category(product.category),
          notes: "Turn order: #{product.sku}"
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
