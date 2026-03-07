module Types
  class PosSaleItemInput < Types::BaseInputObject
    argument :product_id, ID, required: true
    argument :quantity, Integer, required: false, default_value: 1
  end
end
