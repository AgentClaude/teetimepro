require "rails_helper"

RSpec.describe Payments::CreatePaymentService do
  let(:booking) { create(:booking) }
  let(:organization) { booking.tee_time.tee_sheet.course.organization }
  let(:user) { booking.user }

  describe ".call" do
    context "with valid params" do
      it "creates a payment record" do
        result = described_class.call(
          booking: booking,
          organization: organization,
          user: user,
          amount_cents: 15000
        )

        expect(result).to be_success
        payment = result.data.payment
        expect(payment).to be_persisted
        expect(payment.status).to eq("pending")
        expect(payment.amount_cents).to eq(15000)
        expect(payment.organization).to eq(organization)
        expect(payment.user).to eq(user)
        expect(payment.payment_method).to eq("card")
        expect(payment.provider).to eq("stripe")
      end

      it "accepts optional parameters" do
        result = described_class.call(
          booking: booking,
          organization: organization,
          user: user,
          amount_cents: 5000,
          currency: "GBP",
          payment_method: :cash,
          provider: :manual,
          provider_transaction_id: "txn_123",
          metadata: { note: "VIP" }
        )

        expect(result).to be_success
        payment = result.data.payment
        expect(payment.amount_currency).to eq("GBP")
        expect(payment.payment_method).to eq("cash")
        expect(payment.provider).to eq("manual")
        expect(payment.provider_transaction_id).to eq("txn_123")
        expect(payment.metadata).to eq({ "note" => "VIP" })
      end
    end

    context "with missing required params" do
      it "fails without booking" do
        result = described_class.call(
          booking: nil,
          organization: organization,
          user: user,
          amount_cents: 15000
        )

        expect(result).to be_failure
        expect(result.errors).to include("Booking can't be blank")
      end

      it "fails without amount_cents" do
        result = described_class.call(
          booking: booking,
          organization: organization,
          user: user,
          amount_cents: nil
        )

        expect(result).to be_failure
      end
    end
  end
end
