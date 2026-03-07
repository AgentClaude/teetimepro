module Types
  class FnbTabType < Types::BaseObject
    field :id, ID, null: false
    field :golfer_name, String, null: false
    field :status, String, null: false
    field :total_cents, Integer, null: false
    field :opened_at, GraphQL::Types::ISO8601DateTime, null: false
    field :closed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :organization, Types::OrganizationType, null: false
    field :course, Types::CourseType, null: false
    field :user, Types::UserType, null: false, description: "Server who opened the tab"
    field :booking, Types::BookingType, null: true, description: "Linked booking (for turn orders)"
    field :fnb_tab_items, [Types::FnbTabItemType], null: false

    # Turn order fields
    field :turn_order, Boolean, null: false
    field :delivery_hole, Integer, null: true
    field :delivery_notes, String, null: true

    # Computed fields
    field :item_count, Integer, null: false
    field :duration_in_minutes, Integer, null: true
    field :can_be_modified, Boolean, null: false
    field :total_amount, Types::MoneyType, null: false

    def item_count
      object.item_count
    end

    def duration_in_minutes
      object.duration_in_minutes
    end

    def can_be_modified
      object.can_be_modified?
    end

    def total_amount
      object.total_amount
    end
  end
end
