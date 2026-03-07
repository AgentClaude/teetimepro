require "rails_helper"

RSpec.describe Payments::CapturePaymentService do
  describe ".call" do
    context "with an authorized payment" do
      let(:payment) { create(:payment, :authorized) }

      it "captures the payment" do
        result = described_class.call(payment: payment)

        expect(result).to be_success
        expect(result.data.payment.status).to eq("captured")
        expect(result.data.payment.paid_at).to be_present
      end

      it "updates provider_transaction_id if provided" do
        result = described_class.call(
          payment: payment,
          provider_transaction_id: "ch_new_123"
        )

        expect(result).to be_success
        expect(result.data.payment.provider_transaction_id).to eq("ch_new_123")
      end
    end

    context "with a non-authorized payment" do
      let(:payment) { create(:payment, status: :pending) }

      it "fails with error" do
        result = described_class.call(payment: payment)

        expect(result).to be_failure
        expect(result.errors).to include("Payment is not in a capturable state")
      end
    end

    context "without a payment" do
      it "fails validation" do
        result = described_class.call(payment: nil)

        expect(result).to be_failure
        expect(result.errors).to include("Payment can't be blank")
      end
    end
  end
end
