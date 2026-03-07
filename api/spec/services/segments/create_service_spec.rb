require "rails_helper"

RSpec.describe Segments::CreateService, type: :service do
  let(:org) { create(:organization) }
  let(:manager) { create(:user, :manager, organization: org) }
  let(:golfer) { create(:user, organization: org) }

  describe "#call" do
    it "creates a segment with valid params" do
      result = described_class.call(
        organization: org,
        user: manager,
        name: "Active Golfers",
        description: "Golfers who booked recently",
        filter_criteria: { "booking_count_min" => 1 }
      )

      expect(result).to be_success
      expect(result.segment).to be_persisted
      expect(result.segment.name).to eq("Active Golfers")
      expect(result.segment.is_dynamic).to be true
      expect(result.segment.created_by).to eq(manager)
    end

    it "evaluates and caches the count" do
      create(:user, organization: org, role: :golfer)

      result = described_class.call(
        organization: org,
        user: manager,
        name: "All Golfers",
        filter_criteria: {}
      )

      expect(result).to be_success
      expect(result.segment.cached_count).to be >= 0
      expect(result.segment.last_evaluated_at).not_to be_nil
    end

    it "fails for non-manager users" do
      result = described_class.call(
        organization: org,
        user: golfer,
        name: "Test",
        filter_criteria: { "booking_count_min" => 1 }
      )

      expect(result).to be_failure
    end

    it "fails for users from different org" do
      other_org = create(:organization)
      other_manager = create(:user, :manager, organization: other_org)

      result = described_class.call(
        organization: org,
        user: other_manager,
        name: "Test",
        filter_criteria: { "booking_count_min" => 1 }
      )

      expect(result).to be_failure
    end

    it "fails with duplicate name in same org" do
      create(:golfer_segment, organization: org, created_by: manager, name: "VIPs")

      result = described_class.call(
        organization: org,
        user: manager,
        name: "VIPs",
        filter_criteria: { "booking_count_min" => 1 }
      )

      expect(result).to be_failure
    end
  end
end
