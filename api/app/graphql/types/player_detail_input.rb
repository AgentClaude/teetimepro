module Types
  class PlayerDetailInput < Types::BaseInputObject
    description "Input type for individual player details in a booking"

    argument :name, String, required: true, description: "Player's full name"
    argument :email, String, required: false, description: "Player's email address"
    argument :phone, String, required: false, description: "Player's phone number"
  end
end
