module Types
  class InventoryLevelType < Types::BaseObject
    field :id, ID, null: false
    field :pos_product, Types::PosProductType, null: false
    field :course, Types::CourseType, null: false
    field :current_stock, Integer, null: false
    field :reserved_stock, Integer, null: false
    field :available_stock, Integer, null: false
    field :reorder_point, Integer, null: false
    field :reorder_quantity, Integer, null: false
    field :needs_reorder, Boolean, null: false
    field :stock_status, String, null: false
    field :average_cost_cents, Integer
    field :last_cost_cents, Integer
    field :stock_value_cents, Integer, null: false
    field :last_counted_at, GraphQL::Types::ISO8601DateTime
    field :last_counted_by, Types::UserType
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def available_stock
      object.available_stock
    end

    def needs_reorder
      object.needs_reorder?
    end

    def stock_status
      object.stock_status
    end

    def stock_value_cents
      object.stock_value_cents
    end
  end
end