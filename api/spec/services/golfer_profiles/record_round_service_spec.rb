require "rails_helper"

RSpec.describe GolferProfiles::RecordRoundService do
  let(:profile) { create(:golfer_profile) }

  describe ".call" do
    let(:valid_params) do
      {
        golfer_profile: profile,
        course_name: "Augusta National",
        played_on: Date.current,
        score: 82,
        holes_played: 18,
        course_rating: 72.0,
        slope_rating: 137,
        tee_color: "blue"
      }
    end

    context "with valid params" do
      it "creates a round" do
        result = described_class.call(**valid_params)

        expect(result).to be_success
        expect(result.round).to be_persisted
        expect(result.round.course_name).to eq("Augusta National")
        expect(result.round.score).to eq(82)
      end

      it "calculates differential" do
        result = described_class.call(**valid_params)

        expect(result.round.differential).to be_present
      end

      it "updates profile stats" do
        described_class.call(**valid_params)

        profile.reload
        expect(profile.total_rounds).to eq(1)
        expect(profile.best_score).to eq(82)
        expect(profile.last_played_on).to eq(Date.current)
      end
    end

    context "with enough rounds for handicap calculation" do
      before do
        3.times do |i|
          create(:round, golfer_profile: profile, played_on: (i + 1).days.ago)
        end
      end

      it "triggers handicap recalculation" do
        expect(GolferProfiles::CalculateHandicapService).to receive(:call)
          .with(golfer_profile: profile)

        described_class.call(**valid_params)
      end
    end

    context "with invalid params" do
      it "returns failure without course_name" do
        result = described_class.call(golfer_profile: profile, played_on: Date.current, score: 82)

        expect(result).to be_failure
      end

      it "returns failure without score" do
        result = described_class.call(golfer_profile: profile, course_name: "Test", played_on: Date.current)

        expect(result).to be_failure
      end
    end
  end
end
