# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::SendBookingEmailService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.tomorrow) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: Date.tomorrow.beginning_of_day + 9.hours) }
  let(:user) { create(:user, organization: organization, email: "golfer@example.com") }
  let(:booking) { create(:booking, tee_time: tee_time, user: user, status: :confirmed) }

  describe ".call" do
    context "with valid confirmation" do
      it "succeeds" do
        result = described_class.call(booking: booking, email_type: "confirmation")
        expect(result).to be_success
        expect(result.data[:email_type]).to eq("confirmation")
        expect(result.data[:delivered]).to be true
      end
    end

    context "with valid cancellation" do
      it "succeeds" do
        result = described_class.call(booking: booking, email_type: "cancellation")
        expect(result).to be_success
        expect(result.data[:email_type]).to eq("cancellation")
      end
    end

    context "with invalid email type" do
      it "fails validation" do
        result = described_class.call(booking: booking, email_type: "invalid")
        expect(result).not_to be_success
        expect(result.errors).to include(match(/email_type/i))
      end
    end

    context "when user has no email" do
      let(:user) { create(:user, organization: organization, email: nil) }

      it "returns failure" do
        result = described_class.call(booking: booking, email_type: "confirmation")
        expect(result).not_to be_success
        expect(result.errors).to include("User has no email address")
      end
    end

    context "with email provider and template" do
      let!(:provider) do
        create(:email_provider, :sendgrid,
               organization: organization,
               is_default: true,
               verification_status: "verified")
      end
      let!(:template) do
        create(:email_template,
               organization: organization,
               name: "booking_confirmation",
               category: "transactional",
               subject: "Confirmed: {{course_name}} on {{tee_date}}",
               body_html: "<h1>Hi {{first_name}}</h1><p>Your tee time at {{course_name}} is confirmed.</p>")
      end
      let(:mock_adapter) { instance_double(EmailProviders::SendgridAdapter) }

      before do
        allow(provider).to receive(:adapter).and_return(mock_adapter)
        allow(EmailProvider).to receive_message_chain(:active, :find_by).and_return(provider)
        allow(organization).to receive_message_chain(:email_providers, :active, :find_by).and_return(provider)
      end

      it "sends via provider with rendered template" do
        expect(mock_adapter).to receive(:send_email).with(
          to: "golfer@example.com",
          subject: match(/Confirmed/),
          html_body: match(/Hi/),
          text_body: anything
        ).and_return({ success: true, message_id: "msg_123" })

        result = described_class.call(booking: booking, email_type: "confirmation")
        expect(result).to be_success
        expect(result.data[:delivered]).to be true
      end

      it "increments template usage count" do
        allow(mock_adapter).to receive(:send_email)
          .and_return({ success: true, message_id: "msg_123" })

        expect { described_class.call(booking: booking, email_type: "confirmation") }
          .to change { template.reload.usage_count }.by(1)
      end
    end

    context "without email provider (mailer fallback)" do
      it "sends via BookingMailer for confirmation" do
        mailer_double = instance_double(ActionMailer::MessageDelivery)
        expect(BookingMailer).to receive(:confirmation)
          .with(booking: booking, organization: organization)
          .and_return(mailer_double)
        expect(mailer_double).to receive(:deliver_now)

        result = described_class.call(booking: booking, email_type: "confirmation")
        expect(result).to be_success
      end

      it "sends via BookingMailer for cancellation" do
        mailer_double = instance_double(ActionMailer::MessageDelivery)
        expect(BookingMailer).to receive(:cancellation)
          .with(booking: booking, organization: organization)
          .and_return(mailer_double)
        expect(mailer_double).to receive(:deliver_now)

        result = described_class.call(booking: booking, email_type: "cancellation")
        expect(result).to be_success
      end
    end

    context "when email delivery fails" do
      it "returns success with delivered: false (non-blocking)" do
        allow(BookingMailer).to receive(:confirmation).and_raise(StandardError, "SMTP error")

        result = described_class.call(booking: booking, email_type: "confirmation")
        expect(result).to be_success
        expect(result.data[:delivered]).to be false
        expect(result.data[:error]).to include("SMTP error")
      end
    end
  end
end
