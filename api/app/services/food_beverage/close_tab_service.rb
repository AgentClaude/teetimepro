module FoodBeverage
  class CloseTabService < ApplicationService
    attr_accessor :organization, :user, :tab_id, :payment_method

    validates :organization, :user, :tab_id, presence: true

    def call
      return validation_failure(self) unless valid?

      tab = find_tab
      return failure(['Tab not found']) unless tab
      return failure(['Tab is already closed']) if tab.closed? || tab.merged?

      authorize_org_access!(user, organization)

      ActiveRecord::Base.transaction do
        # Calculate final total
        final_total = tab.fnb_tab_items.sum { |item| item.quantity * item.unit_price_cents }
        
        # Close the tab
        tab.update!(
          status: 'closed',
          total_cents: final_total,
          closed_at: Time.current
        )

        # TODO: Integrate with payment processing if payment_method provided
        # payment_result = process_payment(tab) if payment_method.present?

        # Broadcast real-time notification
        broadcast_tab_closed(tab)

        success(tab: tab, final_total_cents: final_total)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    rescue StandardError => e
      failure(["Failed to close tab: #{e.message}"])
    end

    private

    def find_tab
      organization.fnb_tabs.find_by(id: tab_id)
    end

    def process_payment(tab)
      # Future integration with payment service
      # Payments::ProcessPaymentService.call(
      #   amount_cents: tab.total_cents,
      #   payment_method: payment_method,
      #   description: "F&B Tab - #{tab.golfer_name}",
      #   organization: organization
      # )
    end

    def broadcast_tab_closed(tab)
      ActionCable.server.broadcast(
        "fnb_tabs_#{organization.id}",
        {
          type: 'tab.closed',
          tab: {
            id: tab.id,
            golfer_name: tab.golfer_name,
            course_name: tab.course.name,
            server_name: tab.user.full_name,
            total_cents: tab.total_cents,
            item_count: tab.item_count,
            duration_minutes: tab.duration_in_minutes,
            closed_at: tab.closed_at.iso8601
          },
          timestamp: Time.current.iso8601
        }
      )
    end
  end
end