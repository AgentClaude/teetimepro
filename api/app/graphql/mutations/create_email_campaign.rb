# frozen_string_literal: true

module Mutations
  class CreateEmailCampaign < Mutations::BaseMutation
    argument :name, String, required: true
    argument :subject, String, required: true
    argument :body_html, String, required: true
    argument :body_text, String, required: false
    argument :recipient_filter, String, required: false
    argument :filter_criteria, GraphQL::Types::JSON, required: false
    argument :lapsed_days, Integer, required: false
    argument :is_automated, Boolean, required: false
    argument :recurrence_interval_days, Integer, required: false
    argument :scheduled_at, GraphQL::Types::ISO8601DateTime, required: false

    field :email_campaign, Types::EmailCampaignType, null: true
    field :errors, [String], null: false

    def resolve(**args)
      org = require_auth!
      require_role!(:manager)

      result = Campaigns::CreateEmailCampaignService.call(
        organization: org,
        user: current_user,
        **args
      )

      if result.success?
        { email_campaign: result.data[:campaign], errors: [] }
      else
        { email_campaign: nil, errors: result.errors }
      end
    end
  end
end
