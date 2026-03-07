module Types
  class PosProductCategoryEnum < Types::BaseEnum
    value 'FOOD', 'Food items', value: 'food'
    value 'BEVERAGE', 'Beverages', value: 'beverage'
    value 'APPAREL', 'Clothing and accessories', value: 'apparel'
    value 'EQUIPMENT', 'Golf equipment', value: 'equipment'
    value 'RENTAL', 'Rental items (carts, clubs)', value: 'rental'
    value 'OTHER', 'Other items', value: 'other'
  end
end
