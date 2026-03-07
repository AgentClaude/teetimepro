# frozen_string_literal: true

module Notifications
  class SendBookingEmailService < ApplicationService
    attr_accessor :booking, :email_type

    VALID_TYPES = %w[confirmation cancellation].freeze

    BOOKING_MERGE_FIELDS = %w[
      {{first_name}}
      {{last_name}}
      {{full_name}}
      {{email}}
      {{organization_name}}
      {{course_name}}
      {{tee_time}}
      {{tee_date}}
      {{tee_date_short}}
      {{players_count}}
      {{confirmation_code}}
      {{total}}
      {{cancellation_reason}}
      {{refund_status}}
      {{current_date}}
    ].freeze

    validates :booking, :email_type, presence: true
    validate :valid_email_type

    def call
      return validation_failure(self) unless valid?

      user = booking.user
      return failure(["User has no email address"]) if user.email.blank?

      organization = booking.organization

      begin
        provider = organization.email_providers.active.find_by(is_default: true)
        template = find_template(organization)

        if provider && template
          send_via_provider(provider, template, user, organization)
        else
          send_via_mailer(organization)
        end

        log_delivery(user)
        success(booking: booking, email_type: email_type, delivered: true)
      rescue StandardError => e
        Rails.logger.error("Failed to send booking #{email_type} email: #{e.message}")
        # Email failures should not break the booking flow
        success(booking: booking, email_type: email_type, delivered: false, error: e.message)
      end
    end

    private

    def valid_email_type
      return if VALID_TYPES.include?(email_type)

      errors.add(:email_type, "must be one of: #{VALID_TYPES.join(', ')}")
    end

    def find_template(organization)
      # Look for a transactional template matching the email type
      category = email_type == "confirmation" ? "transactional" : "transactional"
      template_name = "booking_#{email_type}"

      organization.email_templates
                  .active
                  .by_category(category)
                  .find_by("LOWER(name) LIKE ?", "%#{template_name}%")
    end

    def send_via_provider(provider, template, user, organization)
      adapter = provider.adapter
      merge_data = build_merge_data(user, organization)

      subject = template.render_subject(merge_data)
      html_body = template.render_html(merge_data)
      text_body = template.render_text(merge_data)

      result = adapter.send_email(
        to: user.email,
        subject: subject,
        html_body: html_body,
        text_body: text_body
      )

      template.increment_usage!

      unless result[:success]
        raise StandardError, "Provider send failed: #{result[:error]}"
      end
    end

    def send_via_mailer(organization)
      case email_type
      when "confirmation"
        BookingMailer.confirmation(booking: booking, organization: organization).deliver_now
      when "cancellation"
        BookingMailer.cancellation(booking: booking, organization: organization).deliver_now
      end
    end

    def build_merge_data(user, organization)
      tee_time = booking.tee_time
      course = tee_time.course

      {
        "first_name" => user.first_name,
        "last_name" => user.last_name,
        "full_name" => user.full_name,
        "email" => user.email,
        "organization_name" => organization.name,
        "course_name" => course.name,
        "tee_time" => tee_time.formatted_time,
        "tee_date" => tee_time.date.strftime("%A, %B %d, %Y"),
        "tee_date_short" => tee_time.date.strftime("%m/%d/%Y"),
        "players_count" => booking.players_count.to_s,
        "confirmation_code" => booking.confirmation_code,
        "total" => booking.total_cents.to_i > 0 ? booking.total.format : "N/A",
        "cancellation_reason" => booking.cancellation_reason || "",
        "refund_status" => booking.payment&.refunded? ? "Refund processed" : "",
        "current_date" => Date.current.strftime("%B %d, %Y")
      }
    end

    def log_delivery(user)
      Rails.logger.info(
        "Booking #{email_type} email sent for #{booking.confirmation_code} to #{user.email}"
      )
    end
  end
end
