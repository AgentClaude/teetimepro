require "rails_helper"

RSpec.describe Scorecards::AbandonScorecardService do
  describe ".call" do
    context "with in-progress scorecard" do
      let(:scorecard) { create(:scorecard, status: "in_progress") }

      it "abandons the scorecard" do
        result = described_class.call(scorecard: scorecard)

        expect(result).to be_success
        expect(result.scorecard.status).to eq("abandoned")
      end
    end

    context "when scorecard is already completed" do
      let(:scorecard) { create(:scorecard, :completed) }

      it "fails with error" do
        result = described_class.call(scorecard: scorecard)

        expect(result).to be_failure
        expect(result.errors).to include("Scorecard is not in progress")
      end
    end

    context "with missing scorecard" do
      it "fails without scorecard" do
        result = described_class.call(scorecard: nil)
        expect(result).to be_failure
      end
    end
  end
end
