# frozen_string_literal: true

module Campaigns
  class ProcessEmailWebhookService < ApplicationService
    attr_accessor :provider, :payload, :headers

    validates :provider, :payload, presence: true

    def call
      return validation_failure(self) unless valid?

      begin
        adapter = provider.adapter
        events = adapter.parse_webhook(payload: payload, headers: headers || {})
        processed = process_events(events)

        success(
          processed_count: processed[:updated],
          skipped_count: processed[:skipped],
          events_count: events.length
        )
      rescue StandardError => e
        failure(["Failed to process webhook: #{e.message}"])
      end
    end

    private

    def process_events(events)
      updated = 0
      skipped = 0

      events.each do |event|
        email_message = find_email_message(event[:message_id])

        if email_message
          apply_event(email_message, event)
          update_campaign_counters(email_message.email_campaign)
          updated += 1
        else
          skipped += 1
        end
      end

      { updated: updated, skipped: skipped }
    end

    def find_email_message(message_id)
      return nil if message_id.blank?

      EmailMessage.find_by(provider_message_id: message_id)
    end

    def apply_event(email_message, event)
      case event[:event_type]
      when :delivered
        email_message.mark_delivered!
      when :opened
        email_message.mark_opened!
      when :clicked
        email_message.mark_clicked!
      when :bounced
        email_message.mark_bounced!(event.dig(:metadata, :reason))
      when :failed
        email_message.mark_failed!(event.dig(:metadata, :reason))
      end
    end

    def update_campaign_counters(campaign)
      return unless campaign

      Campaigns::UpdateCampaignCountersService.call(campaign: campaign)
    end
  end
end
