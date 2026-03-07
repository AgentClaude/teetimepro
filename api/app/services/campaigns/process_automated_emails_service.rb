# frozen_string_literal: true

module Campaigns
  class ProcessAutomatedEmailsService < ApplicationService
    def call
      processed_campaigns = []
      
      EmailCampaign.due_for_automation.find_each do |campaign|
        begin
          result = send_automated_campaign(campaign)
          
          if result.success?
            processed_campaigns << {
              campaign: campaign,
              status: 'sent',
              sent_count: result.data[:sent_count]
            }
          else
            processed_campaigns << {
              campaign: campaign,
              status: 'failed',
              errors: result.errors
            }
          end
        rescue StandardError => e
          Rails.logger.error "Failed to process automated campaign #{campaign.id}: #{e.message}"
          processed_campaigns << {
            campaign: campaign,
            status: 'error',
            error: e.message
          }
        end
      end

      success(
        processed_count: processed_campaigns.count,
        campaigns: processed_campaigns
      )
    end

    private

    def send_automated_campaign(campaign)
      # Create a new campaign based on the automated one
      new_campaign_result = Campaigns::CreateEmailCampaignService.call(
        organization: campaign.organization,
        user: campaign.created_by,
        name: "#{campaign.name} - #{Date.current.strftime('%Y-%m-%d')}",
        subject: campaign.subject,
        body_html: campaign.body_html,
        body_text: campaign.body_text,
        recipient_filter: campaign.recipient_filter,
        filter_criteria: campaign.filter_criteria,
        lapsed_days: campaign.lapsed_days,
        is_automated: false, # The new instance is not automated
        scheduled_at: Time.current
      )

      return new_campaign_result unless new_campaign_result.success?

      # Send the new campaign immediately
      new_campaign = new_campaign_result.data[:campaign]
      Campaigns::SendEmailCampaignService.call(campaign: new_campaign)
    end
  end
end