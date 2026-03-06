module Mutations
  class UpdateCustomer < BaseMutation
    argument :id, ID, required: true
    argument :first_name, String, required: false
    argument :last_name, String, required: false
    argument :email, String, required: false
    argument :phone, String, required: false

    field :customer, Types::UserType, null: true
    field :errors, [String], null: false

    def resolve(id:, **attrs)
      require_auth!
      require_role!(:manager)

      customer = current_organization.users.find(id)
      updates = attrs.compact

      if customer.update(updates)
        { customer: customer, errors: [] }
      else
        { customer: nil, errors: customer.errors.full_messages }
      end
    end
  end
end
