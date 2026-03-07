module Types
  class FnbTabStatusEnum < Types::BaseEnum
    value "OPEN", "Tab is open and accepting new items"
    value "CLOSED", "Tab has been closed and paid"
    value "MERGED", "Tab has been merged into another tab"
  end
end
