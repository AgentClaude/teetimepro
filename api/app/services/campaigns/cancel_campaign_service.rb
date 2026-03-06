# frozen_string_literal: true

module Campaigns
  class CancelCampaignService < ApplicationService
    attr_accessor :campaign

    validates :campaign, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure("Campaign cannot be cancelled in its current state") unless campaign.can_cancel?

      campaign.update!(status: :cancelled)

      # Cancel any pending messages
      campaign.sms_messages.where(status: :pending).update_all(
        status: SmsMessage.statuses[:failed],
        error_message: "Campaign cancelled",
        updated_at: Time.current
      )

      success(campaign: campaign.reload)
    end
  end
end
