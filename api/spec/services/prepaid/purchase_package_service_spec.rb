# frozen_string_literal: true

require "rails_helper"

RSpec.describe Prepaid::PurchasePackageService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:package) { create(:prepaid_package, organization: organization, rounds_included: 10) }

  describe ".call" do
    context "with valid params" do
      it "creates a purchase with correct initial state" do
        result = described_class.call(
          prepaid_package: package,
          user: user,
          organization: organization
        )

        expect(result).to be_success
        purchase = result.data.purchase
        expect(purchase).to be_active
        expect(purchase.rounds_remaining).to eq(10)
        expect(purchase.code).to be_present
        expect(purchase.purchased_at).to be_present
      end
    end

    context "for value_card package" do
      let(:value_package) { create(:prepaid_package, :value_card, organization: organization) }

      it "sets initial balance" do
        result = described_class.call(
          prepaid_package: value_package,
          user: user,
          organization: organization
        )

        expect(result).to be_success
        expect(result.data.purchase.balance_cents).to eq(25000)
      end
    end

    context "with validity_days" do
      let(:timed_package) { create(:prepaid_package, organization: organization, rounds_included: 5, validity_days: 90) }

      it "calculates expiry date" do
        result = described_class.call(
          prepaid_package: timed_package,
          user: user,
          organization: organization
        )

        expect(result).to be_success
        expect(result.data.purchase.expires_at).to be_within(1.minute).of(90.days.from_now)
      end
    end

    context "when package is unavailable" do
      let(:inactive_package) { create(:prepaid_package, :inactive, organization: organization) }

      it "returns failure" do
        result = described_class.call(
          prepaid_package: inactive_package,
          user: user,
          organization: organization
        )

        expect(result).not_to be_success
        expect(result.errors).to include("Package is not available for purchase")
      end
    end

    context "when package belongs to different organization" do
      let(:other_org) { create(:organization) }
      let(:other_package) { create(:prepaid_package, organization: other_org) }

      it "returns failure" do
        result = described_class.call(
          prepaid_package: other_package,
          user: user,
          organization: organization
        )

        expect(result).not_to be_success
        expect(result.errors).to include("Package does not belong to this organization")
      end
    end
  end
end
