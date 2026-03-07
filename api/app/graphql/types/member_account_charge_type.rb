module Types
  class MemberAccountChargeType < BaseObject
    field :id, ID, null: false
    field :charge_type, String, null: false
    field :status, String, null: false
    field :amount_cents, Integer, null: false
    field :amount_currency, String, null: false
    field :description, String, null: false
    field :notes, String, null: true
    field :posted_at, GraphQL::Types::ISO8601DateTime, null: true
    field :voided_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :membership, Types::MembershipType, null: false
    field :charged_by, Types::UserType, null: false
    field :fnb_tab, Types::FnbTabType, null: true
    field :member_name, String, null: true
    field :voidable, Boolean, null: false

    def voidable
      object.voidable?
    end
  end
end
