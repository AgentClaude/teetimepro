# frozen_string_literal: true

module Campaigns
  class UpdateCampaignCountersService < ApplicationService
    attr_accessor :sms_message

    validates :sms_message, presence: true

    def call
      return validation_failure(self) unless valid?

      campaign = sms_message.sms_campaign
      campaign.update!(
        sent_count: campaign.sms_messages.where(status: [:queued, :sent, :delivered]).count,
        delivered_count: campaign.sms_messages.where(status: :delivered).count,
        failed_count: campaign.sms_messages.where(status: [:failed, :undelivered]).count
      )

      # Check if campaign is complete
      total_terminal = campaign.sms_messages.where(status: [:delivered, :failed, :undelivered]).count
      if total_terminal >= campaign.total_recipients && campaign.sending?
        campaign.update!(status: :completed, completed_at: Time.current)
      end

      success(campaign: campaign.reload)
    end
  end
end
