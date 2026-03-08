# frozen_string_literal: true

require "rails_helper"

RSpec.describe Deposits::CollectDepositService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet) }
  let(:booking) { create(:booking, tee_time: tee_time, user: user, total_cents: 10000) }

  describe ".call" do
    context "with valid params" do
      it "creates a deposit payment and updates booking" do
        result = described_class.call(
          booking: booking,
          amount_cents: 5000
        )

        expect(result).to be_success
        expect(result.data.payment).to be_completed
        expect(result.data.payment.amount_cents).to eq(5000)
        expect(result.data.payment.metadata).to eq({ "type" => "deposit" })
        expect(result.data.booking.deposit_cents).to eq(5000)
        expect(result.data.booking.deposit_paid_at).to be_present
      end
    end

    context "when deposit exceeds booking total" do
      it "returns failure" do
        result = described_class.call(
          booking: booking,
          amount_cents: 15000
        )

        expect(result).not_to be_success
        expect(result.errors).to include("Deposit exceeds booking total")
      end
    end

    context "when booking already has deposit" do
      before { booking.update!(deposit_cents: 5000) }

      it "returns failure" do
        result = described_class.call(
          booking: booking,
          amount_cents: 3000
        )

        expect(result).not_to be_success
        expect(result.errors).to include("Booking already has a deposit")
      end
    end

    context "with custom payment method" do
      it "uses specified payment method" do
        result = described_class.call(
          booking: booking,
          amount_cents: 2500,
          payment_method: :cash
        )

        expect(result).to be_success
        expect(result.data.payment).to be_payment_method_cash
      end
    end
  end
end
