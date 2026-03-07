module Types
  class InventoryMovementType < Types::BaseObject
    field :id, ID, null: false
    field :pos_product, Types::PosProductType, null: false
    field :course, Types::CourseType, null: false
    field :performed_by, Types::UserType, null: false
    field :movement_type, String, null: false
    field :quantity, Integer, null: false
    field :formatted_quantity, String, null: false
    field :unit_cost_cents, Integer
    field :total_cost_cents, Integer
    field :notes, String
    field :reference_type, String
    field :reference_id, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def formatted_quantity
      object.formatted_quantity
    end
  end
end