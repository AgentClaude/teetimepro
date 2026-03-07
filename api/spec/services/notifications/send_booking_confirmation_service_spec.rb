require "rails_helper"

RSpec.describe Notifications::SendBookingConfirmationService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization, email: "test@example.com", phone: "+15551234567") }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.tomorrow) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: Date.tomorrow.beginning_of_day + 8.hours) }
  let(:booking) { create(:booking, user: user, tee_time: tee_time, players_count: 2) }

  before do
    # Mock Twilio configuration
    allow(ENV).to receive(:fetch).with("TWILIO_ACCOUNT_SID").and_return("test_sid")
    allow(ENV).to receive(:fetch).with("TWILIO_AUTH_TOKEN").and_return("test_token")
    allow(ENV).to receive(:fetch).with("TWILIO_PHONE_NUMBER").and_return("+15559999999")
    allow(ENV).to receive(:[]).with("TWILIO_ACCOUNT_SID").and_return("test_sid")
    
    # Mock Twilio client
    twilio_client = instance_double(Twilio::REST::Client)
    twilio_messages = instance_double("Twilio::REST::Api::V2010::AccountContext::MessageList")
    allow(Twilio::REST::Client).to receive(:new).and_return(twilio_client)
    allow(twilio_client).to receive(:messages).and_return(twilio_messages)
    allow(twilio_messages).to receive(:create).and_return(true)

    # Mock mailer
    mailer_double = instance_double(ActionMailer::MessageDelivery)
    allow(BookingMailer).to receive(:confirmation_email).and_return(mailer_double)
    allow(mailer_double).to receive(:deliver_later).and_return(true)
  end

  describe ".call" do
    context "with valid booking" do
      it "successfully sends both SMS and email" do
        result = described_class.call(booking: booking)

        expect(result).to be_success
        expect(result.booking).to eq(booking)
        expect(result.sms_sent).to be(true)
        expect(result.email_sent).to be(true)
        expect(result.delivered).to be(true)
        expect(result.errors).to be_empty
      end

      it "sends SMS with correct parameters" do
        twilio_client = instance_double(Twilio::REST::Client)
        twilio_messages = instance_double("Twilio::REST::Api::V2010::AccountContext::MessageList")
        
        allow(Twilio::REST::Client).to receive(:new)
          .with("test_sid", "test_token")
          .and_return(twilio_client)
        allow(twilio_client).to receive(:messages).and_return(twilio_messages)
        
        expect(twilio_messages).to receive(:create).with(
          from: "+15559999999",
          to: "+15551234567",
          body: include("Hi #{user.first_name}! Your tee time is confirmed.")
        )

        described_class.call(booking: booking)
      end

      it "sends email via BookingMailer" do
        expect(BookingMailer).to receive(:confirmation_email).with(booking)
        
        mailer_double = instance_double(ActionMailer::MessageDelivery)
        allow(BookingMailer).to receive(:confirmation_email).and_return(mailer_double)
        expect(mailer_double).to receive(:deliver_later)

        described_class.call(booking: booking)
      end
    end

    context "when user has no phone number" do
      let(:user) { create(:user, organization: organization, email: "test@example.com", phone: nil) }

      it "sends only email and reports SMS as failed" do
        result = described_class.call(booking: booking)

        expect(result).to be_success
        expect(result.sms_sent).to be(false)
        expect(result.email_sent).to be(true)
        expect(result.delivered).to be(true)
        expect(result.errors).to include("No phone number available")
      end
    end

    context "when user has no email" do
      let(:user) { create(:user, organization: organization, email: "", phone: "+15551234567") }

      it "sends only SMS and reports email as failed" do
        result = described_class.call(booking: booking)

        expect(result).to be_success
        expect(result.sms_sent).to be(true)
        expect(result.email_sent).to be(false)
        expect(result.delivered).to be(true)
        expect(result.errors).to include("No email address available")
      end
    end

    context "when Twilio is not configured" do
      before do
        allow(ENV).to receive(:[]).with("TWILIO_ACCOUNT_SID").and_return(nil)
      end

      it "sends only email and reports SMS as failed" do
        result = described_class.call(booking: booking)

        expect(result).to be_success
        expect(result.sms_sent).to be(false)
        expect(result.email_sent).to be(true)
        expect(result.delivered).to be(true)
        expect(result.errors).to include("Twilio not configured")
      end
    end

    context "when SMS fails" do
      before do
        twilio_client = instance_double(Twilio::REST::Client)
        allow(Twilio::REST::Client).to receive(:new).and_return(twilio_client)
        allow(twilio_client).to receive(:messages).and_raise(StandardError.new("SMS service unavailable"))
      end

      it "continues with email and reports SMS failure" do
        result = described_class.call(booking: booking)

        expect(result).to be_success
        expect(result.sms_sent).to be(false)
        expect(result.email_sent).to be(true)
        expect(result.delivered).to be(true)
        expect(result.errors).to include("SMS failed: SMS service unavailable")
      end
    end

    context "when email fails" do
      before do
        allow(BookingMailer).to receive(:confirmation_email).and_raise(StandardError.new("Email service unavailable"))
      end

      it "continues with SMS and reports email failure" do
        result = described_class.call(booking: booking)

        expect(result).to be_success
        expect(result.sms_sent).to be(true)
        expect(result.email_sent).to be(false)
        expect(result.delivered).to be(true)
        expect(result.errors).to include("Email failed: Email service unavailable")
      end
    end

    context "when both SMS and email fail" do
      before do
        allow(ENV).to receive(:[]).with("TWILIO_ACCOUNT_SID").and_return(nil)
        allow(BookingMailer).to receive(:confirmation_email).and_raise(StandardError.new("Email service unavailable"))
      end

      it "reports failure but still returns success to not break booking flow" do
        result = described_class.call(booking: booking)

        expect(result).to be_success  # Service always returns success to not break booking flow
        expect(result.sms_sent).to be(false)
        expect(result.email_sent).to be(false)
        expect(result.delivered).to be(false)
        expect(result.errors.length).to eq(2)
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