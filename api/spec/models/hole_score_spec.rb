require "rails_helper"

RSpec.describe HoleScore, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:scorecard) }
  end

  describe "validations" do
    subject { build(:hole_score) }

    it { is_expected.to validate_presence_of(:hole_number) }
    it { is_expected.to validate_presence_of(:par) }
    it { is_expected.to validate_inclusion_of(:hole_number).in_range(1..18) }
    it { is_expected.to validate_inclusion_of(:par).in_range(3..6) }
  end

  describe "uniqueness" do
    let(:scorecard) { create(:scorecard) }

    it "prevents duplicate hole numbers per scorecard" do
      create(:hole_score, scorecard: scorecard, hole_number: 1, par: 4)
      duplicate = build(:hole_score, scorecard: scorecard, hole_number: 1, par: 4)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:hole_number]).to include("already recorded for this scorecard")
    end
  end

  describe "#calculate_score_to_par" do
    it "sets score_to_par when strokes are present" do
      hole_score = build(:hole_score, par: 4, strokes: 5)
      hole_score.valid?
      hole_score.save!
      expect(hole_score.score_to_par).to eq(1)
    end

    it "sets score_to_par to nil when strokes are nil" do
      hole_score = build(:hole_score, par: 4, strokes: nil)
      hole_score.save!
      expect(hole_score.score_to_par).to be_nil
    end

    it "handles birdie correctly" do
      hole_score = build(:hole_score, par: 4, strokes: 3)
      hole_score.save!
      expect(hole_score.score_to_par).to eq(-1)
    end
  end
end
