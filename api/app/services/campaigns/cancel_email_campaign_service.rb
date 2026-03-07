# frozen_string_literal: true

module Campaigns
  class CancelEmailCampaignService < ApplicationService
    attr_accessor :campaign

    validates :campaign, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Campaign cannot be cancelled in its current state"]) unless campaign.can_cancel?

      campaign.update!(status: :cancelled)

      # Cancel any pending email messages
      campaign.email_messages.where(status: :pending).update_all(
        status: EmailMessage.statuses[:failed],
        error_message: "Campaign cancelled",
        updated_at: Time.current
      )

      success(campaign: campaign.reload)
    end
  end
end
