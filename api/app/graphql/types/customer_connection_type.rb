class Types::CustomerConnectionType < Types::BaseObject
  # Fixed complexity to avoid graphql-ruby complexity calculator issues with nested lists
  def self.complexity_for(query:, child_complexity:, field:, lookahead:)
    child_complexity + 10
  end

  field :nodes, [Types::UserType], null: false
  field :total_count, Integer, null: false
  field :page, Integer, null: false
  field :per_page, Integer, null: false
  field :total_pages, Integer, null: false
end
