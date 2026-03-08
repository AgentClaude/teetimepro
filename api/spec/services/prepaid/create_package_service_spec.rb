# frozen_string_literal: true

require "rails_helper"

RSpec.describe Prepaid::CreatePackageService do
  let(:organization) { create(:organization) }

  describe ".call" do
    context "with valid round_pack params" do
      it "creates a prepaid package" do
        result = described_class.call(
          organization: organization,
          name: "Weekend 10-Pack",
          package_type: "round_pack",
          price_cents: 50000,
          rounds_included: 10
        )

        expect(result).to be_success
        package = result.data.package
        expect(package.name).to eq("Weekend 10-Pack")
        expect(package.round_pack?).to be true
        expect(package.rounds_included).to eq(10)
        expect(package.price_cents).to eq(50000)
        expect(package).to be_active
      end
    end

    context "with valid value_card params" do
      it "creates a value card package" do
        result = described_class.call(
          organization: organization,
          name: "Gift Card $250",
          package_type: "value_card",
          price_cents: 25000,
          value_cents: 25000
        )

        expect(result).to be_success
        expect(result.data.package.value_card?).to be true
        expect(result.data.package.value_cents).to eq(25000)
      end
    end

    context "with restrictions" do
      it "stores restrictions JSON" do
        result = described_class.call(
          organization: organization,
          name: "Weekday Pack",
          package_type: "round_pack",
          price_cents: 30000,
          rounds_included: 10,
          restrictions: { "day_of_week" => ["saturday", "sunday"] }
        )

        expect(result).to be_success
        expect(result.data.package.restricted_days).to eq(["saturday", "sunday"])
      end
    end

    context "with missing required params" do
      it "returns failure" do
        result = described_class.call(
          organization: organization,
          name: nil,
          package_type: "round_pack",
          price_cents: 50000,
          rounds_included: 10
        )

        expect(result).not_to be_success
        expect(result.errors).to include(/Name can't be blank/)
      end
    end
  end
end
