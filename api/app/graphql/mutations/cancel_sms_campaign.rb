# frozen_string_literal: true

module Mutations
  class CancelSmsCampaign < Mutations::BaseMutation
    argument :id, ID, required: true

    field :sms_campaign, Types::SmsCampaignType, null: true
    field :errors, [String], null: false

    def resolve(id:)
      org = require_auth!
      require_role!(:manager)

      campaign = org.sms_campaigns.find(id)

      result = Campaigns::CancelCampaignService.call(campaign: campaign)

      if result.success?
        { sms_campaign: result.campaign, errors: [] }
      else
        { sms_campaign: nil, errors: result.errors }
      end
    end
  end
end
