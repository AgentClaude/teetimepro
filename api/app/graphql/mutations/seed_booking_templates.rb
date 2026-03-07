# frozen_string_literal: true

module Mutations
  class SeedBookingTemplates < BaseMutation
    field :created, [String], null: false
    field :skipped, [String], null: false
    field :errors, [String], null: false

    def resolve
      org = require_auth!
      require_role!(:manager)

      result = Notifications::SeedBookingTemplatesService.call(
        organization: org,
        user: current_user
      )

      if result.success?
        {
          created: result.data[:created],
          skipped: result.data[:skipped],
          errors: []
        }
      else
        { created: [], skipped: [], errors: result.errors }
      end
    end
  end
end
