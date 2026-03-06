# frozen_string_literal: true

class SendScheduledCampaignsJob < ApplicationJob
  queue_as :default

  def perform
    SmsCampaign.pending_send.find_each do |campaign|
      Campaigns::SendCampaignService.call(campaign: campaign)
    end
  end
end
