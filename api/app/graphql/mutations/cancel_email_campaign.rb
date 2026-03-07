# frozen_string_literal: true

module Mutations
  class CancelEmailCampaign < Mutations::BaseMutation
    argument :id, ID, required: true

    field :email_campaign, Types::EmailCampaignType, null: true
    field :errors, [String], null: false

    def resolve(id:)
      org = require_auth!
      require_role!(:manager)

      campaign = org.email_campaigns.find(id)

      # Reuse the existing cancel campaign service
      result = Campaigns::CancelCampaignService.call(campaign: campaign)

      if result.success?
        { email_campaign: result.data[:campaign], errors: [] }
      else
        { email_campaign: nil, errors: result.errors }
      end
    end
  end
end