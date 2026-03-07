module Mutations
  class UpdateHandicap < BaseMutation
    description "Manually update a golfer's handicap index"

    argument :golfer_profile_id, ID, required: true
    argument :handicap_index, Float, required: true
    argument :notes, String, required: false

    field :golfer_profile, Types::GolferProfileType, null: true
    field :errors, [String], null: false

    def resolve(golfer_profile_id:, handicap_index:, notes: nil)
      golfer_profile = GolferProfile.find(golfer_profile_id)
      result = GolferProfiles::UpdateHandicapService.call(
        golfer_profile: golfer_profile,
        handicap_index: handicap_index,
        source: "manual",
        notes: notes
      )

      if result.success?
        { golfer_profile: result.golfer_profile, errors: [] }
      else
        { golfer_profile: nil, errors: result.errors }
      end
    end
  end
end
