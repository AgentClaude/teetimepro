module Types
  class LoyaltyRewardTypeEnum < Types::BaseEnum
    description "Types of loyalty rewards available"

    value "DISCOUNT_PERCENTAGE", "Percentage discount on purchases", value: "discount_percentage"
    value "DISCOUNT_FIXED", "Fixed dollar discount on purchases", value: "discount_fixed"
    value "FREE_ROUND", "Free round of golf", value: "free_round"
    value "PRO_SHOP_CREDIT", "Credit to spend at the pro shop", value: "pro_shop_credit"
  end
end