require "rails_helper"

RSpec.describe TournamentScore, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:tournament_round) }
    it { is_expected.to belong_to(:tournament_entry) }
  end

  describe "validations" do
    subject { build(:tournament_score) }

    it { is_expected.to validate_presence_of(:hole_number) }
    it { is_expected.to validate_presence_of(:strokes) }
    it { is_expected.to validate_presence_of(:par) }
    it { is_expected.to validate_numericality_of(:hole_number).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:strokes).is_greater_than(0) }
  end

  describe "#score_to_par" do
    it "returns the difference between strokes and par" do
      score = build(:tournament_score, strokes: 5, par: 4)
      expect(score.score_to_par).to eq(1)
    end

    it "returns negative for under-par scores" do
      score = build(:tournament_score, strokes: 3, par: 4)
      expect(score.score_to_par).to eq(-1)
    end
  end

  describe "#score_label" do
    it "returns birdie for -1" do
      score = build(:tournament_score, :birdie)
      expect(score.score_label).to eq("birdie")
    end

    it "returns eagle for -2" do
      score = build(:tournament_score, :eagle)
      expect(score.score_label).to eq("eagle")
    end

    it "returns par for even" do
      score = build(:tournament_score, strokes: 4, par: 4)
      expect(score.score_label).to eq("par")
    end

    it "returns bogey for +1" do
      score = build(:tournament_score, :bogey)
      expect(score.score_label).to eq("bogey")
    end

    it "returns double_bogey for +2" do
      score = build(:tournament_score, :double_bogey)
      expect(score.score_label).to eq("double_bogey")
    end
  end

  describe "boolean helpers" do
    it "#birdie? returns true for -1" do
      expect(build(:tournament_score, :birdie).birdie?).to be true
    end

    it "#eagle_or_better? returns true for -2 or less" do
      expect(build(:tournament_score, :eagle).eagle_or_better?).to be true
    end

    it "#bogey? returns true for +1" do
      expect(build(:tournament_score, :bogey).bogey?).to be true
    end
  end
end
