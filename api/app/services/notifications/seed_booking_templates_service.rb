# frozen_string_literal: true

module Notifications
  class SeedBookingTemplatesService < ApplicationService
    attr_accessor :organization, :user

    validates :organization, :user, presence: true

    TEMPLATES = [
      {
        name: "booking_confirmation",
        subject: "⛳ Booking Confirmed — {{course_name}} on {{tee_date}}",
        category: "transactional",
        body_html: <<~HTML
          <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 24px;">
            <div style="text-align: center; padding: 24px 0;">
              <h1 style="color: #166534; font-size: 24px; margin: 0;">⛳ Booking Confirmed!</h1>
            </div>
            <div style="background: #ffffff; border-radius: 12px; padding: 32px; border: 1px solid #e4e4e7;">
              <p>Hi {{first_name}},</p>
              <p>Your tee time at <strong>{{course_name}}</strong> has been confirmed. Here are your booking details:</p>
              <table style="width: 100%; border-collapse: collapse; margin: 24px 0;">
                <tr>
                  <td style="padding: 10px 0; border-bottom: 1px solid #e4e4e7; color: #71717a; font-size: 14px;">Date</td>
                  <td style="padding: 10px 0; border-bottom: 1px solid #e4e4e7; font-weight: 600; text-align: right;">{{tee_date}}</td>
                </tr>
                <tr>
                  <td style="padding: 10px 0; border-bottom: 1px solid #e4e4e7; color: #71717a; font-size: 14px;">Tee Time</td>
                  <td style="padding: 10px 0; border-bottom: 1px solid #e4e4e7; font-weight: 600; text-align: right;">{{tee_time}}</td>
                </tr>
                <tr>
                  <td style="padding: 10px 0; border-bottom: 1px solid #e4e4e7; color: #71717a; font-size: 14px;">Players</td>
                  <td style="padding: 10px 0; border-bottom: 1px solid #e4e4e7; font-weight: 600; text-align: right;">{{players_count}}</td>
                </tr>
                <tr>
                  <td style="padding: 10px 0; color: #71717a; font-size: 14px;">Confirmation Code</td>
                  <td style="padding: 10px 0; font-weight: 600; text-align: right; font-family: monospace; letter-spacing: 2px;">{{confirmation_code}}</td>
                </tr>
              </table>
              <p style="margin-top: 24px; font-size: 14px; color: #71717a;">
                Please arrive at least 15 minutes before your tee time. If you need to cancel or modify your booking,
                please contact us with your confirmation code.
              </p>
            </div>
            <div style="text-align: center; padding: 24px 0; font-size: 12px; color: #71717a;">
              <p>{{organization_name}}</p>
            </div>
          </div>
        HTML
      },
      {
        name: "booking_cancellation",
        subject: "Booking Cancelled — {{course_name}} on {{tee_date}}",
        category: "transactional",
        body_html: <<~HTML
          <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 24px;">
            <div style="text-align: center; padding: 24px 0;">
              <h1 style="color: #dc2626; font-size: 24px; margin: 0;">Booking Cancelled</h1>
            </div>
            <div style="background: #ffffff; border-radius: 12px; padding: 32px; border: 1px solid #e4e4e7;">
              <p>Hi {{first_name}},</p>
              <p>Your booking at <strong>{{course_name}}</strong> has been cancelled.</p>
              <table style="width: 100%; border-collapse: collapse; margin: 24px 0;">
                <tr>
                  <td style="padding: 10px 0; border-bottom: 1px solid #e4e4e7; color: #71717a; font-size: 14px;">Date</td>
                  <td style="padding: 10px 0; border-bottom: 1px solid #e4e4e7; font-weight: 600; text-align: right;">{{tee_date}}</td>
                </tr>
                <tr>
                  <td style="padding: 10px 0; border-bottom: 1px solid #e4e4e7; color: #71717a; font-size: 14px;">Tee Time</td>
                  <td style="padding: 10px 0; border-bottom: 1px solid #e4e4e7; font-weight: 600; text-align: right;">{{tee_time}}</td>
                </tr>
                <tr>
                  <td style="padding: 10px 0; color: #71717a; font-size: 14px;">Confirmation Code</td>
                  <td style="padding: 10px 0; font-weight: 600; text-align: right; font-family: monospace;">{{confirmation_code}}</td>
                </tr>
              </table>
              <p style="margin-top: 24px; font-size: 14px; color: #71717a;">
                Would you like to rebook? Visit our website or call us to schedule a new tee time.
              </p>
            </div>
            <div style="text-align: center; padding: 24px 0; font-size: 12px; color: #71717a;">
              <p>{{organization_name}}</p>
            </div>
          </div>
        HTML
      }
    ].freeze

    def call
      return validation_failure(self) unless valid?

      created = []
      skipped = []

      TEMPLATES.each do |template_attrs|
        existing = organization.email_templates.find_by(name: template_attrs[:name])

        if existing
          skipped << template_attrs[:name]
          next
        end

        template = organization.email_templates.create!(
          created_by: user,
          name: template_attrs[:name],
          subject: template_attrs[:subject],
          body_html: template_attrs[:body_html],
          category: template_attrs[:category],
          merge_fields: Notifications::SendBookingEmailService::BOOKING_MERGE_FIELDS
        )

        created << template.name
      end

      success(created: created, skipped: skipped)
    rescue StandardError => e
      failure(["Failed to seed booking templates: #{e.message}"])
    end
  end
end
