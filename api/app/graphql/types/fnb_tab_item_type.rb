module Types
  class FnbTabItemType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :quantity, Integer, null: false
    field :unit_price_cents, Integer, null: false
    field :total_cents, Integer, null: false
    field :category, String, null: false
    field :notes, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :fnb_tab, Types::FnbTabType, null: false
    field :added_by, Types::UserType, null: false, description: "Staff member who added the item"

    # Computed fields
    field :unit_price_amount, Types::MoneyType, null: false
    field :total_amount, Types::MoneyType, null: false
    field :can_be_modified, Boolean, null: false

    def unit_price_amount
      object.unit_price_amount
    end

    def total_amount
      object.total_amount
    end

    def can_be_modified
      object.can_be_modified?
    end
  end
end