module Types
  class PublicMutationType < Types::BaseObject
    field :create_public_booking, mutation: Mutations::CreatePublicBooking
  end
end