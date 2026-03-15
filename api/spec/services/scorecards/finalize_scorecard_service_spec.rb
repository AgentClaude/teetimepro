require "rails_helper"

RSpec.describe Scorecards::FinalizeScorecardService do
  describe ".call" do
    context "with scored holes" do
      let(:scorecard) { create(:scorecard, :with_scored_holes) }

      it "finalizes the scorecard" do
        result = described_class.call(scorecard: scorecard)

        expect(result).to be_success
        expect(result.scorecard.status).to eq("completed")
        expect(result.scorecard.completed_at).to be_present
      end

      it "recalculates totals" do
        result = described_class.call(scorecard: scorecard)

        expect(result.scorecard.total_strokes).to be_present
        expect(result.scorecard.score_to_par).to be_present
      end

      it "creates a round record" do
        result = described_class.call(scorecard: scorecard)

        expect(result.round).to be_a(Round)
        expect(result.scorecard.round).to eq(result.round)
      end
    end

    context "with no scored holes" do
      let(:scorecard) { create(:scorecard, :with_hole_scores) }

      it "fails with error" do
        result = described_class.call(scorecard: scorecard)

        expect(result).to be_failure
        expect(result.errors).to include("No holes have been scored yet")
      end
    end

    context "when scorecard is not in progress" do
      let(:scorecard) { create(:scorecard, :completed, :with_scored_holes) }

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
