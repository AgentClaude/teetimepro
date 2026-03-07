module Types
  class MemberAccountStatementType < BaseObject
    field :membership, Types::MembershipType, null: false
    field :charges, [Types::MemberAccountChargeType], null: false
    field :total_count, Integer, null: false
    field :current_balance_cents, Integer, null: false
    field :credit_limit_cents, Integer, null: false
    field :available_credit_cents, Integer, null: false
    field :period_total_cents, Integer, null: false
    field :page, Integer, null: false
    field :per_page, Integer, null: false
    field :total_pages, Integer, null: false
  end
end
