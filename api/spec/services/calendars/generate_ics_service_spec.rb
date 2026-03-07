require "rails_helper"

RSpec.describe Calendars::GenerateIcsService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:course) { create(:course, organization: organization, name: "Pebble Beach Golf Links", address: "1700 17-Mile Drive", city: "Pebble Beach", state: "CA", zip_code: "93953") }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.tomorrow) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: DateTime.tomorrow.beginning_of_day + 14.hours) }
  let(:booking) { create(:booking, tee_time: tee_time, user: user, players_count: 4, confirmation_code: "ABC123", notes: "Birthday celebration") }

  before do
    # Create booking players
    create(:booking_player, booking: booking, name: "John Smith")
    create(:booking_player, booking: booking, name: "Jane Doe")
    create(:booking_player, booking: booking, name: "Bob Johnson")
    create(:booking_player, booking: booking, name: "Alice Brown")
  end

  describe ".call" do
    context "with valid booking" do
      it "generates ICS content successfully" do
        result = described_class.call(booking: booking)

        expect(result).to be_success
        expect(result.ics_content).to be_present
        expect(result.filename).to be_present
      end

      it "includes correct event details" do
        result = described_class.call(booking: booking)
        ics_content = result.ics_content

        expect(ics_content).to include("Golf at Pebble Beach Golf Links")
        expect(ics_content).to include("Confirmation Code: ABC123")
        expect(ics_content).to include("Players: 4")
        expect(ics_content).to include("John Smith")
        expect(ics_content).to include("Jane Doe")
        expect(ics_content).to include("Birthday celebration")
        expect(ics_content).to include("Pebble Beach Golf Links")
        expect(ics_content).to include("1700 17-Mile Drive")
      end

      it "sets correct date and time" do
        result = described_class.call(booking: booking)
        ics_content = result.ics_content

        # Check that DTSTART is included with correct format
        expect(ics_content).to match(/DTSTART:\d{8}T\d{6}Z/)
        expect(ics_content).to match(/DTEND:\d{8}T\d{6}Z/)
      end

      it "includes reminder alarm" do
        result = described_class.call(booking: booking)
        ics_content = result.ics_content

        expect(ics_content).to include("BEGIN:VALARM")
        expect(ics_content).to include("ACTION:DISPLAY")
        expect(ics_content).to include("TRIGGER:-PT1H")
      end

      it "generates appropriate filename" do
        result = described_class.call(booking: booking)

        expect(result.filename).to include("golf-booking")
        expect(result.filename).to include("pebble-beach-golf-links")
        expect(result.filename).to end_with(".ics")
      end

      it "includes unique UID" do
        result = described_class.call(booking: booking)
        ics_content = result.ics_content

        expect(ics_content).to include("UID:booking-#{booking.id}@teetimespro.com")
      end
    end

    context "with missing booking" do
      it "returns validation failure" do
        result = described_class.call(booking: nil)

        expect(result).to be_failure
        expect(result.errors).to include("Booking can't be blank")
      end
    end

    context "with booking without players" do
      let(:simple_booking) { create(:booking, tee_time: tee_time, user: user, players_count: 1) }

      it "still generates ICS content" do
        result = described_class.call(booking: simple_booking)

        expect(result).to be_success
        expect(result.ics_content).to be_present
      end
    end

    context "with booking without notes" do
      let(:booking_no_notes) { create(:booking, tee_time: tee_time, user: user, notes: nil) }

      it "generates ICS content without notes section" do
        result = described_class.call(booking: booking_no_notes)

        expect(result).to be_success
        expect(result.ics_content).not_to include("Notes:")
      end
    end
  end
end