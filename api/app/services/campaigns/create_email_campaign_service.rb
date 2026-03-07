# frozen_string_literal: true

module Campaigns
  class CreateEmailCampaignService < ApplicationService
    attr_accessor :organization, :user, :name, :subject, :body_html, :body_text,
                  :recipient_filter, :filter_criteria, :lapsed_days,
                  :is_automated, :recurrence_interval_days, :scheduled_at

    validates :organization, :user, :name, :subject, :body_html, presence: true
    validates :lapsed_days, presence: true, numericality: { greater_than: 0 }
    validates :recurrence_interval_days, numericality: { greater_than: 0, allow_nil: true }

    def call
      return validation_failure(self) unless valid?

      authorize_org_access!(user, organization)
      authorize_role!(user, :manager)

      campaign = EmailCampaign.new(
        organization: organization,
        created_by: user,
        name: name,
        subject: subject,
        body_html: body_html,
        body_text: body_text || strip_html(body_html),
        recipient_filter: recipient_filter || "all",
        filter_criteria: filter_criteria || {},
        lapsed_days: lapsed_days || 30,
        is_automated: is_automated || false,
        recurrence_interval_days: recurrence_interval_days,
        scheduled_at: scheduled_at,
        status: determine_initial_status
      )

      if campaign.save
        success(campaign: campaign)
      else
        validation_failure(campaign)
      end
    end

    private

    def determine_initial_status
      if scheduled_at.present?
        :scheduled
      elsif is_automated
        :scheduled # Automated campaigns are immediately scheduled
      else
        :draft
      end
    end

    def strip_html(html_content)
      # Simple HTML stripping for text version
      html_content&.gsub(/<[^>]*>/, '')&.gsub(/\s+/, ' ')&.strip
    end
  end
end