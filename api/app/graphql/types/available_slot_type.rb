module Types
  class AvailableSlotType < Types::BaseObject
    description "An available tee time slot with pricing information"

    field :tee_time_id, ID, null: false
    field :course_id, ID, null: false
    field :course_name, String, null: false
    field :date, GraphQL::Types::ISO8601Date, null: false
    field :starts_at, GraphQL::Types::ISO8601DateTime, null: false
    field :formatted_time, String, null: false
    field :available_spots, Integer, null: false
    field :max_players, Integer, null: false
    field :booked_players, Integer, null: false
    field :base_price_cents, Integer, null: true
    field :dynamic_price_cents, Integer, null: true
    field :price_per_player_cents, Integer, null: true
    field :total_price_cents, Integer, null: true
    field :has_dynamic_pricing, Boolean, null: false
    field :applied_rules, [String], null: false

    field :formatted_base_price, String, null: true
    field :formatted_dynamic_price, String, null: true
    field :formatted_total_price, String, null: true

    def formatted_base_price
      return nil unless object[:base_price_cents]
      Money.new(object[:base_price_cents]).format
    end

    def formatted_dynamic_price
      return nil unless object[:dynamic_price_cents]
      Money.new(object[:dynamic_price_cents]).format
    end

    def formatted_total_price
      return nil unless object[:total_price_cents]
      Money.new(object[:total_price_cents]).format
    end
  end
end
