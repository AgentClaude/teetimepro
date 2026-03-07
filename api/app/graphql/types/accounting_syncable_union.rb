module Types
  class AccountingSyncableUnion < Types::BaseUnion
    possible_types Types::BookingType, Types::PaymentType

    def self.resolve_type(object, context)
      case object
      when Booking
        Types::BookingType
      when Payment
        Types::PaymentType
      else
        raise "Unexpected AccountingSync syncable type: #{object.class}"
      end
    end
  end
end
