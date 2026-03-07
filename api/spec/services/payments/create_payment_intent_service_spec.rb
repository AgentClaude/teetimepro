require "rails_helper"

RSpec.describe Payments::CreatePaymentIntentService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, price_cents: 5000) }
  let(:players_count) { 2 }

  describe ".call" do
    before do
      # Mock Stripe PaymentIntent creation
      allow(Stripe::PaymentIntent).to receive(:create).and_return(
        double(
          id: "pi_test_123456789",
          client_secret: "pi_test_123456789_secret_test123",
          amount: 10000,
          currency: "usd"
        )
      )
    end

    context "with valid parameters" do
      it "creates a payment intent successfully" do
        result = described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: players_count
        )

        expect(result).to be_success
        expect(result.data.client_secret).to eq("pi_test_123456789_secret_test123")
        expect(result.data.payment_intent_id).to eq("pi_test_123456789")
      end

      it "calculates the correct amount" do
        described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: players_count
        )

        expect(Stripe::PaymentIntent).to have_received(:create).with(
          hash_including(
            amount: 10000, # 5000 cents * 2 players
            currency: "usd"
          )
        )
      end

      it "includes automatic payment methods" do
        described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: players_count
        )

        expect(Stripe::PaymentIntent).to have_received(:create).with(
          hash_including(
            automatic_payment_methods: { enabled: true }
          )
        )
      end

      it "includes metadata" do
        described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: players_count
        )

        expect(Stripe::PaymentIntent).to have_received(:create).with(
          hash_including(
            metadata: {
              tee_time_id: tee_time.id,
              user_id: user.id,
              organization_id: organization.id
            }
          )
        )
      end

      context "with connected Stripe account" do
        before do
          allow(organization).to receive(:stripe_account_id).and_return("acct_test_123")
          allow(organization).to receive(:respond_to?).with(:stripe_account_id).and_return(true)
        end

        it "includes transfer_data for connected account" do
          described_class.call(
            organization: organization,
            tee_time: tee_time,
            user: user,
            players_count: players_count
          )

          expect(Stripe::PaymentIntent).to have_received(:create).with(
            hash_including(
              transfer_data: { destination: "acct_test_123" }
            )
          )
        end
      end

      context "without connected Stripe account" do
        before do
          allow(organization).to receive(:stripe_account_id).and_return(nil)
          allow(organization).to receive(:respond_to?).with(:stripe_account_id).and_return(true)
        end

        it "does not include transfer_data" do
          described_class.call(
            organization: organization,
            tee_time: tee_time,
            user: user,
            players_count: players_count
          )

          expect(Stripe::PaymentIntent).to have_received(:create).with(
            hash_not_including(:transfer_data)
          )
        end
      end
    end

    context "with invalid parameters" do
      it "fails when tee_time is missing" do
        result = described_class.call(
          organization: organization,
          tee_time: nil,
          user: user,
          players_count: players_count
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/tee_time/i))
      end

      it "fails when players_count is missing" do
        result = described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: nil
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/players_count/i))
      end

      it "fails when user is missing" do
        result = described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: nil,
          players_count: players_count
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/user/i))
      end

      it "fails when organization is missing" do
        result = described_class.call(
          organization: nil,
          tee_time: tee_time,
          user: user,
          players_count: players_count
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/organization/i))
      end
    end

    context "when Stripe raises an error" do
      before do
        allow(Stripe::PaymentIntent).to receive(:create).and_raise(
          Stripe::CardError.new("Your card was declined.", "card_declined")
        )
      end

      it "handles Stripe errors gracefully" do
        result = described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: players_count
        )

        expect(result).to be_failure
        expect(result.errors).to include("Payment setup failed: Your card was declined.")
      end
    end

    context "when Stripe raises a generic error" do
      before do
        allow(Stripe::PaymentIntent).to receive(:create).and_raise(
          Stripe::StripeError.new("API error occurred.")
        )
      end

      it "handles generic Stripe errors" do
        result = described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: players_count
        )

        expect(result).to be_failure
        expect(result.errors).to include("Payment setup failed: API error occurred.")
      end
    end
  end
end