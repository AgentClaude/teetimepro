# frozen_string_literal: true

module Campaigns
  class CreateCampaignService < ApplicationService
    attr_accessor :organization, :user, :name, :message_body,
                  :recipient_filter, :filter_criteria, :scheduled_at

    validates :organization, :user, :name, :message_body, presence: true

    def call
      return validation_failure(self) unless valid?

      campaign = SmsCampaign.new(
        organization: organization,
        created_by: user,
        name: name,
        message_body: message_body,
        recipient_filter: recipient_filter || "all",
        filter_criteria: filter_criteria || {},
        scheduled_at: scheduled_at,
        status: scheduled_at.present? ? :scheduled : :draft
      )

      if campaign.save
        success(campaign: campaign)
      else
        validation_failure(campaign)
      end
    end
  end
end
