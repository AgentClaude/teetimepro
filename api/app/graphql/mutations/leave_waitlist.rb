# frozen_string_literal: true

module Mutations
  class LeaveWaitlist < BaseMutation
    argument :tee_time_id, ID, required: true

    field :waitlist_entry, Types::WaitlistEntryType, null: true
    field :errors, [String], null: false

    def resolve(tee_time_id:)
      require_auth!

      tee_time = TeeTime.joins(tee_sheet: { course: :organization })
                        .where(courses: { organization_id: current_organization.id })
                        .find(tee_time_id)

      result = Waitlists::LeaveService.call(
        user: current_user,
        tee_time: tee_time
      )

      if result.success?
        { waitlist_entry: result.data.waitlist_entry, errors: [] }
      else
        { waitlist_entry: nil, errors: result.errors }
      end
    end
  end
end
