require "rails_helper"

RSpec.describe GolferProfiles::CalculateHandicapService do
  let(:profile) { create(:golfer_profile, handicap_index: nil) }

  describe ".call" do
    context "with fewer than 3 eligible rounds" do
      before do
        2.times { |i| create(:round, golfer_profile: profile, played_on: i.days.ago) }
      end

      it "returns failure" do
        result = described_class.call(golfer_profile: profile)

        expect(result).to be_failure
        expect(result.error_message).to include("at least 3 rounds")
      end
    end

    context "with 3 eligible rounds" do
      before do
        # Create 3 rounds with known differentials
        # Score 85, rating 72.5, slope 130 → diff = (113/130)*(85-72.5) = 10.9
        # Score 80, rating 72.5, slope 130 → diff = (113/130)*(80-72.5) = 6.5
        # Score 90, rating 72.5, slope 130 → diff = (113/130)*(90-72.5) = 15.2
        create(:round, golfer_profile: profile, score: 85, course_rating: 72.5, slope_rating: 130, played_on: 3.days.ago)
        create(:round, golfer_profile: profile, score: 80, course_rating: 72.5, slope_rating: 130, played_on: 2.days.ago)
        create(:round, golfer_profile: profile, score: 90, course_rating: 72.5, slope_rating: 130, played_on: 1.day.ago)
      end

      it "calculates handicap using best 1 differential" do
        result = described_class.call(golfer_profile: profile)

        expect(result).to be_success
        # Best 1 of 3: differential 6.5
        expect(result.handicap_index).to eq(6.5)
      end

      it "updates the golfer profile" do
        described_class.call(golfer_profile: profile)

        profile.reload
        expect(profile.handicap_index).to eq(6.5)
        expect(profile.handicap_updated_at).to be_present
      end

      it "creates a handicap revision" do
        expect {
          described_class.call(golfer_profile: profile)
        }.to change(HandicapRevision, :count).by(1)

        revision = profile.handicap_revisions.last
        expect(revision.handicap_index).to eq(6.5)
        expect(revision.source).to eq("calculated")
        expect(revision.rounds_used).to eq(1)
      end
    end

    context "with 10 eligible rounds" do
      before do
        scores = [80, 82, 84, 86, 88, 90, 92, 94, 96, 98]
        scores.each_with_index do |score, i|
          create(:round,
            golfer_profile: profile,
            score: score,
            course_rating: 72.0,
            slope_rating: 125,
            played_on: (10 - i).days.ago
          )
        end
      end

      it "uses best 3 differentials" do
        result = described_class.call(golfer_profile: profile)

        expect(result).to be_success
        expect(result.rounds_used).to eq(3)
      end
    end
  end
end
