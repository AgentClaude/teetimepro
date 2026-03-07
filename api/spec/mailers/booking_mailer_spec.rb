# frozen_string_literal: true

require "rails_helper"

RSpec.describe BookingMailer, type: :mailer do
  let(:organization) { create(:organization, name: "Pine Valley Golf Club") }
  let(:course) { create(:course, organization: organization, name: "Pine Valley") }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.tomorrow) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: Date.tomorrow.beginning_of_day + 9.hours) }
  let(:user) { create(:user, organization: organization, email: "golfer@example.com", first_name: "John") }
  let(:booking) { create(:booking, tee_time: tee_time, user: user, status: :confirmed) }

  describe "#confirmation" do
    let(:mail) { described_class.confirmation(booking: booking, organization: organization) }

    it "renders the headers" do
      expect(mail.to).to eq(["golfer@example.com"])
      expect(mail.subject).to include("Booking Confirmed")
      expect(mail.subject).to include("Pine Valley")
    end

    it "renders the HTML body with booking details" do
      expect(mail.html_part.body.to_s).to include("Booking Confirmed")
      expect(mail.html_part.body.to_s).to include(booking.confirmation_code)
      expect(mail.html_part.body.to_s).to include("John")
    end

    it "renders the text body" do
      expect(mail.text_part.body.to_s).to include("Booking Confirmed")
      expect(mail.text_part.body.to_s).to include(booking.confirmation_code)
    end
  end

  describe "#cancellation" do
    let(:mail) { described_class.cancellation(booking: booking, organization: organization) }

    before { booking.update!(status: :cancelled, cancellation_reason: "Schedule conflict") }

    it "renders the headers" do
      expect(mail.to).to eq(["golfer@example.com"])
      expect(mail.subject).to include("Booking Cancelled")
    end

    it "renders the HTML body" do
      expect(mail.html_part.body.to_s).to include("Booking Cancelled")
      expect(mail.html_part.body.to_s).to include(booking.confirmation_code)
    end

    it "includes cancellation reason when present" do
      expect(mail.html_part.body.to_s).to include("Schedule conflict")
    end
  end
end
