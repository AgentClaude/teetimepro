require "rails_helper"

RSpec.describe Payments::RefundPaymentService do
  describe ".call" do
    context "with a captured stripe payment" do
      let(:payment) { create(:payment, :captured, amount_cents: 10000) }

      before do
        allow(Stripe::Refund).to receive(:create).and_return(
          double(id: "re_123", amount: 10000)
        )
      end

      it "processes a full refund" do
        result = described_class.call(payment: payment, reason: "Customer request")

        expect(result).to be_success
        expect(result.data.payment.status).to eq("refunded")
        expect(result.data.payment.refund_amount_cents).to eq(10000)
        expect(result.data.payment.refund_reason).to eq("Customer request")
        expect(result.data.payment.refunded_at).to be_present
      end

      it "processes a partial refund" do
        result = described_class.call(payment: payment, amount_cents: 5000)

        expect(result).to be_success
        expect(result.data.payment.status).to eq("partially_refunded")
        expect(result.data.payment.refund_amount_cents).to eq(5000)
      end

      it "fails if amount exceeds remaining balance" do
        result = described_class.call(payment: payment, amount_cents: 20000)

        expect(result).to be_failure
        expect(result.errors).to include("Refund amount exceeds remaining balance")
      end
    end

    context "with a manual payment" do
      let(:payment) { create(:payment, :captured, :manual, amount_cents: 5000) }

      it "processes refund without Stripe" do
        result = described_class.call(payment: payment)

        expect(result).to be_success
        expect(result.data.payment.status).to eq("refunded")
        expect(Stripe::Refund).not_to receive(:create)
      end
    end

    context "with a non-refundable payment" do
      let(:payment) { create(:payment, status: :pending) }

      it "fails with error" do
        result = described_class.call(payment: payment)

        expect(result).to be_failure
        expect(result.errors).to include("Payment is not eligible for refund")
      end
    end

    context "when Stripe fails" do
      let(:payment) { create(:payment, :captured, amount_cents: 10000) }

      before do
        allow(Stripe::Refund).to receive(:create)
          .and_raise(Stripe::StripeError.new("Card declined"))
      end

      it "returns failure" do
        result = described_class.call(payment: payment)

        expect(result).to be_failure
        expect(result.errors.first).to include("Refund failed")
      end
    end
  end
end
