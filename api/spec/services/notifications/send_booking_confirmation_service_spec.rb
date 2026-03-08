require "rails_helper"

RSpec.describe Notifications::SendBookingConfirmationService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization, email: "test@example.com", phone: "+15551234567") }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.tomorrow) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: Date.tomorrow.beginning_of_day + 8.hours) }
  let(:booking) { create(:booking, user: user, tee_time: tee_time, players_count: 2) }

  let(:twilio_client) { instance_double("Twilio::REST::Client") }
  let(:twilio_messages) { instance_double("Twilio::REST::Api::V2010::AccountContext::MessageList") }

  before do
    # Mock TwilioConfig
    allow(TwilioConfig).to receive(:configured?).and_return(true)
    allow(TwilioConfig).to receive(:client).and_return(twilio_client)
    allow(TwilioConfig).to receive(:from_number).and_return("+15559999999")
    allow(twilio_client).to receive(:messages).and_return(twilio_messages)
    allow(twilio_messages).to receive(:create).and_return(true)

    # Mock SendBookingEmailService
    allow(Notifications::SendBookingEmailService).to receive(:call).and_return(
      ServiceResult.new(success: true, data: { delivered: true })
    )
  end

  describe ".call" do
    context "with valid booking" do
      it "returns success" do
        result = described_class.call(booking: booking)

        expect(result).to be_success
        expect(result.delivered).to be(true)
      end

      it "sends SMS via TwilioConfig" do
        expect(twilio_messages).to receive(:create).with(
          hash_including(
            from: "+15559999999",
            to: "+15551234567"
          )
        )

        described_class.call(booking: booking)
      end

      it "sends email via SendBookingEmailService" do
        expect(Notifications::SendBookingEmailService).to receive(:call).with(
          booking: booking,
          email_type: "confirmation"
        )

        described_class.call(booking: booking)
      end
    end

    context "when user has no phone number" do
      let(:user) { create(:user, organization: organization, email: "test@example.com", phone: nil) }

      it "still returns success (SMS is skipped)" do
        result = described_class.call(booking: booking)

        expect(result).to be_success
        expect(result.delivered).to be(true)
      end

      it "does not attempt to send SMS" do
        expect(twilio_messages).not_to receive(:create)

        described_class.call(booking: booking)
      end
    end

    context "when Twilio is not configured" do
      before do
        allow(TwilioConfig).to receive(:configured?).and_return(false)
      end

      it "skips SMS but still returns success" do
        result = described_class.call(booking: booking)

        expect(result).to be_success
      end
    end

    context "when SMS fails" do
      before do
        allow(twilio_client).to receive(:messages).and_raise(StandardError.new("SMS service unavailable"))
      end

      it "rescues and returns success to not break booking flow" do
        result = described_class.call(booking: booking)

        expect(result).to be_success
        expect(result.delivered).to be(false)
      end
    end

    context "when email fails" do
      before do
        allow(Notifications::SendBookingEmailService).to receive(:call).and_raise(StandardError.new("Email service unavailable"))
      end

      it "rescues and returns success to not break booking flow" do
        result = described_class.call(booking: booking)

        expect(result).to be_success
        expect(result.delivered).to be(false)
      end
    end

    context "with invalid booking" do
      it "returns validation failure" do
        result = described_class.call(booking: nil)

        expect(result).to be_failure
      end
    end

    context "when unexpected error occurs" do
      before do
        allow(booking).to receive(:user).and_raise(StandardError.new("Unexpected error"))
      end

      it "rescues and returns success with error to not break booking flow" do
        result = described_class.call(booking: booking)

        expect(result).to be_success
        expect(result.delivered).to be(false)
        expect(result.error).to eq("Unexpected error")
      end
    end
  end

  describe "SMS message content" do
    let(:service) { described_class.new(booking: booking) }

    it "includes all required booking details" do
      allow(tee_time).to receive(:formatted_time).and_return("8:00 AM")
      message = service.send(:build_confirmation_message, user, tee_time, course)

      expect(message).to include(user.first_name)
      expect(message).to include(course.name)
      expect(message).to include("8:00 AM")
      expect(message).to include(tee_time.date.strftime('%B %d, %Y'))
      expect(message).to include(booking.players_count.to_s)
      expect(message).to include(booking.confirmation_code)
    end
  end
end
