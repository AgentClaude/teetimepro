require "rails_helper"

RSpec.describe Scorecard, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:golfer_profile) }
    it { is_expected.to belong_to(:course) }
    it { is_expected.to belong_to(:booking).optional }
    it { is_expected.to belong_to(:round).optional }
    it { is_expected.to have_many(:hole_scores).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:played_on) }
    it { is_expected.to validate_presence_of(:holes_played) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:holes_played).in_array([9, 18]) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[in_progress completed abandoned]) }
  end

  describe "scopes" do
    let!(:in_progress) { create(:scorecard, status: "in_progress") }
    let!(:completed) { create(:scorecard, :completed) }
    let!(:abandoned) { create(:scorecard, :abandoned) }

    it ".in_progress returns only in-progress scorecards" do
      expect(described_class.in_progress).to contain_exactly(in_progress)
    end

    it ".completed returns only completed scorecards" do
      expect(described_class.completed).to contain_exactly(completed)
    end

    it ".recent orders by played_on desc" do
      results = described_class.recent
      expect(results.to_a).to include(in_progress, completed, abandoned)
    end
  end

  describe "#holes_completed" do
    let(:scorecard) { create(:scorecard, :with_hole_scores) }

    it "returns count of scored holes" do
      scorecard.hole_scores.first(5).each { |hs| hs.update!(strokes: 4) }
      expect(scorecard.holes_completed).to eq(5)
    end

    it "returns 0 when no holes are scored" do
      expect(scorecard.holes_completed).to eq(0)
    end
  end

  describe "#recalculate_totals!" do
    let(:scorecard) { create(:scorecard, :with_scored_holes) }

    it "calculates total strokes" do
      expect(scorecard.total_strokes).to be_present
      expect(scorecard.total_strokes).to eq(scorecard.hole_scores.sum(:strokes))
    end

    it "calculates front and back nine" do
      front = scorecard.hole_scores.where(hole_number: 1..9).sum(:strokes)
      back = scorecard.hole_scores.where(hole_number: 10..18).sum(:strokes)
      expect(scorecard.front_nine_strokes).to eq(front)
      expect(scorecard.back_nine_strokes).to eq(back)
    end

    it "calculates score to par" do
      total_par = scorecard.hole_scores.sum(:par)
      expect(scorecard.score_to_par).to eq(scorecard.total_strokes - total_par)
    end
  end

  describe "status helpers" do
    it "#in_progress? returns true for in_progress status" do
      scorecard = build(:scorecard, status: "in_progress")
      expect(scorecard.in_progress?).to be true
    end

    it "#completed? returns true for completed status" do
      scorecard = build(:scorecard, status: "completed")
      expect(scorecard.completed?).to be true
    end

    it "#abandoned? returns true for abandoned status" do
      scorecard = build(:scorecard, status: "abandoned")
      expect(scorecard.abandoned?).to be true
    end
  end
end
