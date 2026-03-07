module Types
  class TeeTimeType < Types::BaseObject
    field :id, ID, null: false
    field :starts_at, GraphQL::Types::ISO8601DateTime, null: false
    field :formatted_time, String, null: false
    field :status, String, null: false
    field :max_players, Integer, null: false
    field :booked_players, Integer, null: false
    field :available_spots, Integer, null: false
    field :price_cents, Integer, null: true
    field :price, String, null: true do
      description "Formatted base price"
    end
    field :dynamic_price_cents, Integer, null: true
    field :dynamic_price, String, null: true do
      description "Formatted dynamic price (after applying pricing rules)"
    end
    field :has_dynamic_pricing, Boolean, null: false do
      description "Whether any pricing rules apply to this tee time"
    end
    field :notes, String, null: true
    field :tee_sheet_id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :bookings, [Types::BookingType], null: false
    field :pricing_calculation, Types::PricingCalculationType, null: true do
      description "Detailed pricing calculation for this tee time"
    end

    def price
      return nil unless object.price_cents
      Money.new(object.price_cents).format
    end

    def dynamic_price_cents
      pricing_result = calculate_dynamic_price
      return object.price_cents unless pricing_result&.success?
      
      pricing_result.dynamic_price_cents
    end

    def dynamic_price
      cents = dynamic_price_cents
      return nil unless cents
      Money.new(cents).format
    end

    def has_dynamic_pricing
      pricing_result = calculate_dynamic_price
      return false unless pricing_result&.success?
      
      pricing_result.applied_rules.any?
    end

    def pricing_calculation
      pricing_result = calculate_dynamic_price
      return nil unless pricing_result&.success?
      
      pricing_result.data
    end

    def bookings
      object.bookings.where.not(status: :cancelled)
    end

    private

    def calculate_dynamic_price
      @pricing_calculation ||= begin
        return nil unless object.price_cents&.positive?
        
        Pricing::CalculatePriceService.call(tee_time: object)
      rescue => e
        Rails.logger.error "Error calculating dynamic price for tee time #{object.id}: #{e.message}"
        nil
      end
    end
  end
end
