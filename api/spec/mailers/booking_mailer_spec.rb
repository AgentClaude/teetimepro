require "rails_helper"

RSpec.describe BookingMailer do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization, email: "golfer@example.com", first_name: "John") }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.tomorrow) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: Date.tomorrow.beginning_of_day + 9.hours + 30.minutes) }
  let(:booking) { create(:booking, user: user, tee_time: tee_time, players_count: 3, confirmation_code: "ABC123XY") }

  before do
    # Mock tee_time.formatted_time if the method doesn't exist
    allow(tee_time).to receive(:formatted_time).and_return("9:30 AM")
  end

  describe "#confirmation_email" do
    let(:mail) { described_class.confirmation_email(booking) }

    it "renders the correct headers" do
      expect(mail.subject).to eq("Tee Time Confirmed - #{course.name} - #{Date.tomorrow.strftime('%A, %B %d, %Y')}")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([ENV.fetch("MAILER_FROM_EMAIL", "noreply@teetimespro.com")])
    end

    it "renders the body with booking details" do
      expect(mail.body.encoded).to include(user.first_name)
      expect(mail.body.encoded).to include(course.name)
      expect(mail.body.encoded).to include("9:30 AM")
      expect(mail.body.encoded).to include(Date.tomorrow.strftime('%A, %B %d, %Y'))
      expect(mail.body.encoded).to include("3 players")
      expect(mail.body.encoded).to include(booking.confirmation_code)
    end

    it "includes organization name" do
      expect(mail.body.encoded).to include(organization.name)
    end

    it "includes confirmation code prominently" do
      expect(mail.body.encoded).to include("ABC123XY")
    end

    it "includes cancellation policy information" do
      expect(mail.body.encoded).to include("Cancellation Policy")
    end

    context "when booking is cancellable" do
      before do
        allow(booking).to receive(:cancellable?).and_return(true)
      end

      it "shows the standard cancellation policy" do
        expect(mail.body.encoded).to include("You can cancel this booking up to 24 hours before")
      end
    end

    context "when booking is not cancellable" do
      before do
        allow(booking).to receive(:cancellable?).and_return(false)
      end

      it "shows the non-cancellable policy" do
        expect(mail.body.encoded).to include("This booking cannot be cancelled")
      end
    end

    describe "HTML email" do
      it "includes HTML styling and structure" do
        html_part = mail.html_part || mail
        expect(html_part.body.encoded).to include("<html>")
        expect(html_part.body.encoded).to include("container")
        expect(html_part.body.encoded).to include("⛳")
      end
    end

    describe "Text email" do
      it "includes plain text formatting" do
        text_part = mail.text_part || mail
        expect(text_part.body.encoded).to include("TEE TIME CONFIRMED!")
        expect(text_part.body.encoded).to include("BOOKING DETAILS:")
        expect(text_part.body.encoded).to include("Course:")
        expect(text_part.body.encoded).to include("Date:")
        expect(text_part.body.encoded).to include("Time:")
        expect(text_part.body.encoded).to include("Players:")
      end
    end
  end

  describe "#cancellation_email" do
    let(:mail) { described_class.cancellation_email(booking) }

    before do
      # Simulate a cancelled booking
      allow(booking).to receive(:status).and_return("cancelled")
    end

    it "renders the correct headers" do
      expect(mail.subject).to eq("Tee Time Cancelled - #{course.name} - #{Date.tomorrow.strftime('%A, %B %d, %Y')}")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([ENV.fetch("MAILER_FROM_EMAIL", "noreply@teetimespro.com")])
    end

    it "renders the body with cancellation details" do
      expect(mail.body.encoded).to include(user.first_name)
      expect(mail.body.encoded).to include(course.name)
      expect(mail.body.encoded).to include("9:30 AM")
      expect(mail.body.encoded).to include(Date.tomorrow.strftime('%A, %B %d, %Y'))
      expect(mail.body.encoded).to include("3 players")
      expect(mail.body.encoded).to include(booking.confirmation_code)
    end

    it "includes cancellation-specific messaging" do
      expect(mail.body.encoded).to include("cancelled")
      expect(mail.body.encoded).to include("Refund Information")
    end

    context "when booking is refundable" do
      before do
        allow(booking).to receive(:refundable?).and_return(true)
      end

      it "shows refund processing information" do
        expect(mail.body.encoded).to include("Your payment will be refunded within 3-5 business days")
      end
    end

    context "when booking is a late cancel" do
      before do
        allow(booking).to receive(:refundable?).and_return(false)
        allow(booking).to receive(:late_cancel?).and_return(true)
      end

      it "shows late cancellation policy" do
        expect(mail.body.encoded).to include("This was a late cancellation")
      end
    end

    context "when booking is not refundable" do
      before do
        allow(booking).to receive(:refundable?).and_return(false)
        allow(booking).to receive(:late_cancel?).and_return(false)
      end

      it "shows contact pro shop message" do
        expect(mail.body.encoded).to include("Please contact the pro shop for information about refunds")
      end
    end

    describe "HTML email" do
      it "includes HTML styling with appropriate cancellation theme" do
        html_part = mail.html_part || mail
        expect(html_part.body.encoded).to include("<html>")
        expect(html_part.body.encoded).to include("TEE TIME CANCELLED")
        expect(html_part.body.encoded).to include("⛳")
      end
    end

    describe "Text email" do
      it "includes plain text cancellation formatting" do
        text_part = mail.text_part || mail
        expect(text_part.body.encoded).to include("TEE TIME CANCELLED")
        expect(text_part.body.encoded).to include("CANCELLED BOOKING DETAILS:")
        expect(text_part.body.encoded).to include("CANCELLED BOOKING: ABC123XY")
        expect(text_part.body.encoded).to include("REFUND INFORMATION:")
      end
    end
  end

  describe "mailer configuration" do
    it "uses ApplicationMailer as the parent class" do
      expect(described_class.superclass).to eq(ApplicationMailer)
    end

    it "inherits default from address" do
      mail = described_class.confirmation_email(booking)
      expect(mail.from).to eq([ENV.fetch("MAILER_FROM_EMAIL", "noreply@teetimespro.com")])
    end
  end
end