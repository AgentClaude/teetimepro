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
        send_emails_via_provider
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

    def email_provider
      @email_provider ||= campaign.email_provider || campaign.organization.email_providers.active.find_by(is_default: true)
    end

    def identify_recipients
      case campaign.recipient_filter
      when "all"
        campaign.organization.users.where(role: [:member, :player])
                .where.not(email: [nil, ""])
      when "members_only"
        campaign.organization.users.joins(:memberships)
                .where(memberships: { status: :active })
                .where.not(email: [nil, ""])
      when "recent_bookers"
        campaign.organization.users
                .joins(:bookings)
                .where(bookings: { created_at: 30.days.ago.. })
                .where.not(email: [nil, ""])
                .distinct
      when "inactive"
        campaign.organization.users
                .where(role: [:member, :player])
                .where.not(id: campaign.organization.bookings.where(created_at: 90.days.ago..).select(:user_id))
                .where.not(email: [nil, ""])
      when "lapsed"
        identify_lapsed_golfers
      when "segment"
        identify_segment_recipients
      else
        campaign.organization.users.where.not(email: [nil, ""])
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
        raise StandardError, "Failed to identify lapsed golfers: #{result.errors.join(", ")}"
      end
    end

    def identify_segment_recipients
      segment_id = campaign.filter_criteria&.dig("segment_id")
      raise StandardError, "No segment specified" if segment_id.blank?

      segment = campaign.organization.golfer_segments.find(segment_id)
      segment.users.where.not(email: [nil, ""])
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

      EmailMessage.insert_all(email_messages_data) if email_messages_data.any?
    end

    def send_emails_via_provider
      if email_provider
        send_via_external_provider
      else
        send_via_rails_mailer
      end
    end

    # Send through SendGrid/Mailchimp provider
    def send_via_external_provider
      adapter = email_provider.adapter
      template = campaign.email_template

      campaign.email_messages.pending.find_each(batch_size: 100) do |email_message|
        merge_data = build_merge_data(email_message.user)
        subject = template ? template.render_subject(merge_data) : campaign.subject
        html_body = template ? template.render_html(merge_data) : personalize_content(campaign.body_html, merge_data)
        text_body = template ? template.render_text(merge_data) : campaign.body_text

        result = adapter.send_email(
          to: email_message.to_email,
          subject: subject,
          html_body: html_body,
          text_body: text_body
        )

        if result[:success]
          email_message.update!(
            status: :sent,
            sent_at: Time.current,
            provider_message_id: result[:message_id]
          )
        else
          email_message.mark_failed!(result[:error])
        end

        update_campaign_counters
      end
    end

    # Fallback: send via Rails mailer (no provider configured)
    def send_via_rails_mailer
      campaign.email_messages.pending.find_each(batch_size: 100) do |email_message|
        begin
          ReengagementMailer.lapsed_golfer_email(email_message.user, campaign).deliver_now
          email_message.mark_sent!
        rescue StandardError => e
          email_message.mark_failed!(e.message)
        end
        update_campaign_counters
      end
    end

    def build_merge_data(user)
      {
        "first_name" => user.first_name,
        "last_name" => user.last_name,
        "full_name" => user.full_name,
        "email" => user.email,
        "organization_name" => campaign.organization.name,
        "current_date" => Date.current.strftime("%B %d, %Y")
      }
    end

    def personalize_content(html, merge_data)
      rendered = html.dup
      merge_data.each { |key, value| rendered.gsub!("{{#{key}}}", value.to_s) }
      rendered
    end

    def update_campaign_counters
      campaign.reload
      campaign.update!(
        sent_count: campaign.email_messages.successful.count,
        failed_count: campaign.email_messages.unsuccessful.count,
        delivered_count: campaign.email_messages.where(status: [:delivered, :opened, :clicked]).count,
        opened_count: campaign.email_messages.where(status: [:opened, :clicked]).count,
        clicked_count: campaign.email_messages.where(status: :clicked).count
      )
    end
  end
end
