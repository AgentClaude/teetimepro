# frozen_string_literal: true

module Campaigns
  class SendEmailCampaignService < ApplicationService
    attr_accessor :campaign

    validates :campaign, presence: true
    validate :campaign_can_be_sent

    def call
      return validation_failure(self) unless valid?

      campaign.update!(status: :sending)

      begin
        recipients = identify_recipients
        campaign.update!(total_recipients: recipients.count)

        create_email_messages(recipients)
        send_emails
        campaign.update!(status: :completed, sent_at: Time.current, completed_at: Time.current)

        success(campaign: campaign, sent_count: campaign.sent_count)
      rescue StandardError => e
        campaign.update!(status: :failed)
        failure(["Failed to send campaign: #{e.message}"])
      end
    end

    private

    def campaign_can_be_sent
      errors.add(:campaign, "cannot be sent") unless campaign&.can_send?
    end

    def identify_recipients
      case campaign.recipient_filter
      when 'all'
        campaign.organization.users.where(role: [:member, :player])
                .where.not(email: [nil, ''])
      when 'members_only'
        campaign.organization.users.joins(:memberships)
                .where(memberships: { status: :active })
                .where.not(email: [nil, ''])
      when 'lapsed'
        identify_lapsed_golfers
      else
        []
      end
    end

    def identify_lapsed_golfers
      result = Campaigns::IdentifyLapsedGolfersService.call(
        organization: campaign.organization,
        lapsed_days: campaign.lapsed_days,
        filter_criteria: campaign.filter_criteria
      )

      if result.success?
        result.data[:golfers]
      else
        raise StandardError, "Failed to identify lapsed golfers: #{result.errors.join(', ')}"
      end
    end

    def create_email_messages(recipients)
      email_messages_data = recipients.map do |user|
        {
          email_campaign_id: campaign.id,
          user_id: user.id,
          to_email: user.email,
          status: :pending,
          created_at: Time.current,
          updated_at: Time.current
        }
      end

      EmailMessage.insert_all(email_messages_data)
    end

    def send_emails
      campaign.email_messages.pending.find_each(batch_size: 100) do |email_message|
        begin
          ReengagementMailer.lapsed_golfer_email(email_message.user, campaign).deliver_now
          email_message.mark_sent!
          update_campaign_counters
        rescue StandardError => e
          email_message.mark_failed!(e.message)
          update_campaign_counters
        end
      end
    end

    def update_campaign_counters
      campaign.reload
      campaign.update!(
        sent_count: campaign.email_messages.successful.count,
        failed_count: campaign.email_messages.unsuccessful.count
      )
    end
  end
end
