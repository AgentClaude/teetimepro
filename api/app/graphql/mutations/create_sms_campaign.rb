# frozen_string_literal: true

module Mutations
  class CreateSmsCampaign < Mutations::BaseMutation
    argument :name, String, required: true
    argument :message_body, String, required: true
    argument :recipient_filter, String, required: false
    argument :filter_criteria, GraphQL::Types::JSON, required: false
    argument :scheduled_at, GraphQL::Types::ISO8601DateTime, required: false

    field :sms_campaign, Types::SmsCampaignType, null: true
    field :errors, [String], null: false

    def resolve(**args)
      org = require_auth!
      require_role!(:manager)

      result = Campaigns::CreateCampaignService.call(
        organization: org,
        user: current_user,
        **args
      )

      if result.success?
        { sms_campaign: result.campaign, errors: [] }
      else
        { sms_campaign: nil, errors: result.errors }
      end
    end
  end
end
