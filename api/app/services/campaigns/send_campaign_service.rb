# frozen_string_literal: true

module Campaigns
  class SendCampaignService < ApplicationService
    attr_accessor :campaign

    validates :campaign, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure("Campaign cannot be sent in its current state") unless campaign.can_send?
      return failure("Twilio is not configured") unless TwilioConfig.configured?

      recipients = resolve_recipients
      return failure("No recipients found matching the filter criteria") if recipients.empty?

      campaign.update!(
        status: :sending,
        total_recipients: recipients.count,
        sent_at: Time.current
      )

      # Create SmsMessage records and enqueue individual sends
      recipients.find_each do |user|
        phone = normalize_phone(user.phone)
        next if phone.blank?

        message = campaign.sms_messages.create!(
          user: user,
          to_phone: phone,
          status: :pending
        )

        SendSmsJob.perform_later(message.id)
      end

      # Update total after filtering out users without phones
      campaign.update!(total_recipients: campaign.sms_messages.count)

      if campaign.sms_messages.count.zero?
        campaign.update!(status: :failed)
        return failure("No recipients had valid phone numbers")
      end

      success(campaign: campaign.reload)
    end

    private

    def resolve_recipients
      base_scope = campaign.organization.users.where.not(phone: [nil, ""])

      case campaign.recipient_filter
      when "all"
        base_scope
      when "members_only"
        base_scope.joins(:memberships).where(memberships: { status: :active })
      when "recent_bookers"
        days = campaign.filter_criteria.fetch("days_back", 30)
        base_scope.joins(:bookings).where("bookings.created_at >= ?", days.days.ago).distinct
      when "inactive"
        days = campaign.filter_criteria.fetch("inactive_days", 90)
        active_user_ids = User.joins(:bookings)
          .where("bookings.created_at >= ?", days.days.ago)
          .select(:id)
        base_scope.where.not(id: active_user_ids)
      when "custom"
        apply_custom_filters(base_scope)
      else
        base_scope
      end
    end

    def apply_custom_filters(scope)
      criteria = campaign.filter_criteria

      if criteria["role"].present?
        scope = scope.where(role: criteria["role"])
      end

      if criteria["min_bookings"].present?
        scope = scope.joins(:bookings)
          .group("users.id")
          .having("COUNT(bookings.id) >= ?", criteria["min_bookings"])
      end

      scope
    end

    def normalize_phone(phone)
      return nil if phone.blank?

      # Strip non-digits, ensure E.164 format
      digits = phone.gsub(/\D/, "")
      return nil if digits.length < 10

      digits = "1#{digits}" if digits.length == 10 # Assume US
      "+#{digits}"
    end
  end
end
