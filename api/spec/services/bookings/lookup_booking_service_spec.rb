require "rails_helper"

RSpec.describe Bookings::LookupBookingService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization, email: "golfer@example.com") }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.tomorrow) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: Date.tomorrow.beginning_of_day + 10.hours) }
  let!(:booking) do
    create(:booking,
      user: user,
      tee_time: tee_time,
      confirmation_code: "ABC12345",
      status: "confirmed"
    )
  end

  describe ".call" do
    context "with valid confirmation code and email" do
      it "returns the booking" do
        result = described_class.call(
          confirmation_code: "ABC12345",
          email: "golfer@example.com"
        )

        expect(result).to be_success
        expect(result.data[:booking]).to eq(booking)
      end

      it "is case-insensitive for confirmation code" do
        result = described_class.call(
          confirmation_code: "abc12345",
          email: "golfer@example.com"
        )

        expect(result).to be_success
        expect(result.data[:booking]).to eq(booking)
      end

      it "is case-insensitive for email" do
        result = described_class.call(
          confirmation_code: "ABC12345",
          email: "Golfer@Example.COM"
        )

        expect(result).to be_success
        expect(result.data[:booking]).to eq(booking)
      end

      it "strips whitespace from inputs" do
        result = described_class.call(
          confirmation_code: "  ABC12345  ",
          email: "  golfer@example.com  "
        )

        expect(result).to be_success
        expect(result.data[:booking]).to eq(booking)
      end
    end

    context "with wrong confirmation code" do
      it "returns failure" do
        result = described_class.call(
          confirmation_code: "WRONG123",
          email: "golfer@example.com"
        )

        expect(result).not_to be_success
        expect(result.errors).to include(/not found/i)
      end
    end

    context "with wrong email" do
      it "returns failure" do
        result = described_class.call(
          confirmation_code: "ABC12345",
          email: "wrong@example.com"
        )

        expect(result).not_to be_success
        expect(result.errors).to include(/not found/i)
      end
    end

    context "with missing confirmation code" do
      it "returns validation failure" do
        result = described_class.call(
          confirmation_code: "",
          email: "golfer@example.com"
        )

        expect(result).not_to be_success
      end
    end

    context "with missing email" do
      it "returns validation failure" do
        result = described_class.call(
          confirmation_code: "ABC12345",
          email: ""
        )

        expect(result).not_to be_success
      end
    end
  end
end
