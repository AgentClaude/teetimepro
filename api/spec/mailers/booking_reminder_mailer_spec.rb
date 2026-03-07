# frozen_string_literal: true

require "rails_helper"

RSpec.describe BookingReminderMailer do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.tomorrow) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: Date.tomorrow.beginning_of_day + 9.hours) }
  let(:user) { create(:user, organization: organization, email: "golfer@example.com", first_name: "Tiger") }
  let(:booking) { create(:booking, tee_time: tee_time, user: user, status: :confirmed) }

  describe "#reminder_24h" do
    let(:mail) { described_class.reminder_24h(booking: booking, organization: organization) }

    it "renders the subject" do
      expect(mail.subject).to include("Reminder")
      expect(mail.subject).to include(course.name)
    end

    it "sends to the user's email" do
      expect(mail.to).to eq(["golfer@example.com"])
    end

    it "includes booking details in the body" do
      expect(mail.body.encoded).to include(booking.confirmation_code)
      expect(mail.body.encoded).to include(course.name)
    end
  end

  describe "#morning_of" do
    let(:mail) { described_class.morning_of(booking: booking, organization: organization) }

    it "renders the subject with time" do
      expect(mail.subject).to include("Today's Tee Time")
      expect(mail.subject).to include(course.name)
    end

    it "sends to the user's email" do
      expect(mail.to).to eq(["golfer@example.com"])
    end

    it "includes the user's first name" do
      expect(mail.body.encoded).to include("Tiger")
    end
  end
end
