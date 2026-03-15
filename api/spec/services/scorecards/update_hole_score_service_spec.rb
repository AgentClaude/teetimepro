require "rails_helper"

RSpec.describe Scorecards::UpdateHoleScoreService do
  let(:scorecard) { create(:scorecard, :with_hole_scores) }

  describe ".call" do
    context "with valid params" do
      it "updates strokes for a hole" do
        result = described_class.call(
          scorecard: scorecard,
          hole_number: 1,
          strokes: 5
        )

        expect(result).to be_success
        expect(result.hole_score.strokes).to eq(5)
        expect(result.hole_score.hole_number).to eq(1)
      end

      it "updates detailed stats" do
        result = described_class.call(
          scorecard: scorecard,
          hole_number: 1,
          strokes: 4,
          putts: 2,
          fairway_hit: true,
          green_in_regulation: true,
          penalties: 0
        )

        expect(result).to be_success
        expect(result.hole_score.putts).to eq(2)
        expect(result.hole_score.fairway_hit).to be true
        expect(result.hole_score.green_in_regulation).to be true
      end

      it "recalculates scorecard totals" do
        described_class.call(scorecard: scorecard, hole_number: 1, strokes: 4)
        described_class.call(scorecard: scorecard, hole_number: 2, strokes: 5)

        scorecard.reload
        expect(scorecard.total_strokes).to be_present
      end

      it "returns updated scorecard" do
        result = described_class.call(
          scorecard: scorecard,
          hole_number: 1,
          strokes: 4
        )

        expect(result.scorecard).to be_a(Scorecard)
        expect(result.scorecard.total_strokes).to be_present
      end
    end

    context "with invalid hole number" do
      it "fails for non-existent hole" do
        result = described_class.call(
          scorecard: scorecard,
          hole_number: 99,
          strokes: 4
        )

        expect(result).to be_failure
        expect(result.errors).to include("Hole 99 not found on this scorecard")
      end
    end

    context "when scorecard is not in progress" do
      let(:scorecard) { create(:scorecard, :completed, :with_scored_holes) }

      it "fails with error" do
        result = described_class.call(
          scorecard: scorecard,
          hole_number: 1,
          strokes: 4
        )

        expect(result).to be_failure
        expect(result.errors).to include("Scorecard is not in progress")
      end
    end

    context "with missing required params" do
      it "fails without scorecard" do
        result = described_class.call(scorecard: nil, hole_number: 1, strokes: 4)
        expect(result).to be_failure
      end

      it "fails without hole_number" do
        result = described_class.call(scorecard: scorecard, hole_number: nil, strokes: 4)
        expect(result).to be_failure
      end
    end
  end
end
