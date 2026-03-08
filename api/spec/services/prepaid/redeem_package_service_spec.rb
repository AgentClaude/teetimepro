# frozen_string_literal: true

require "rails_helper"

RSpec.describe Prepaid::RedeemPackageService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet) }
  let(:booking) { create(:booking, tee_time: tee_time, user: user) }

  describe ".call" do
    context "round_pack redemption" do
      let(:package) { create(:prepaid_package, organization: organization, rounds_included: 5) }
      let(:purchase) { create(:prepaid_purchase, prepaid_package: package, user: user, organization: organization) }

      it "decrements rounds_remaining" do
        result = described_class.call(
          prepaid_purchase: purchase,
          booking: booking,
          user: user
        )

        expect(result).to be_success
        expect(result.data.purchase.rounds_remaining).to eq(4)
      end

      it "creates a redemption record" do
        expect {
          described_class.call(
            prepaid_purchase: purchase,
            booking: booking,
            user: user
          )
        }.to change(PrepaidRedemption, :count).by(1)

        redemption = PrepaidRedemption.last
        expect(redemption.round?).to be true
        expect(redemption.rounds_used).to eq(1)
      end

      it "marks as fully_redeemed when last round used" do
        purchase.update!(rounds_remaining: 1)

        result = described_class.call(
          prepaid_purchase: purchase,
          booking: booking,
          user: user
        )

        expect(result).to be_success
        expect(result.data.purchase).to be_fully_redeemed
      end
    end

    context "value_card redemption" do
      let(:value_package) { create(:prepaid_package, :value_card, organization: organization) }
      let(:purchase) { create(:prepaid_purchase, prepaid_package: value_package, user: user, organization: organization) }

      it "deducts from balance" do
        result = described_class.call(
          prepaid_purchase: purchase,
          booking: booking,
          user: user,
          value_cents: 5000
        )

        expect(result).to be_success
        expect(result.data.purchase.balance_cents).to eq(20000) # 25000 - 5000
      end

      it "caps redemption at available balance" do
        purchase.update!(balance_cents: 3000)

        result = described_class.call(
          prepaid_purchase: purchase,
          booking: booking,
          user: user,
          value_cents: 5000
        )

        expect(result).to be_success
        expect(result.data.purchase.balance_cents).to eq(0)
      end
    end

    context "when purchase is not usable" do
      let(:package) { create(:prepaid_package, organization: organization, rounds_included: 5) }
      let(:purchase) { create(:prepaid_purchase, :expired, prepaid_package: package, user: user, organization: organization) }

      it "returns failure" do
        result = described_class.call(
          prepaid_purchase: purchase,
          booking: booking,
          user: user
        )

        expect(result).not_to be_success
        expect(result.errors).to include("Package is not usable")
      end
    end

    context "when unauthorized user" do
      let(:package) { create(:prepaid_package, organization: organization, rounds_included: 5, transferable: false) }
      let(:purchase) { create(:prepaid_purchase, prepaid_package: package, user: user, organization: organization) }
      let(:other_user) { create(:user, organization: organization) }

      it "returns failure for non-transferable package" do
        result = described_class.call(
          prepaid_purchase: purchase,
          booking: booking,
          user: other_user
        )

        expect(result).not_to be_success
        expect(result.errors).to include("User does not own this package")
      end
    end

    context "transferable package" do
      let(:package) { create(:prepaid_package, organization: organization, rounds_included: 5, transferable: true) }
      let(:purchase) { create(:prepaid_purchase, prepaid_package: package, user: user, organization: organization) }
      let(:other_user) { create(:user, organization: organization) }

      it "allows redemption by another user in same org" do
        result = described_class.call(
          prepaid_purchase: purchase,
          booking: booking,
          user: other_user
        )

        expect(result).to be_success
      end
    end
  end
end
