require "rails_helper"

RSpec.describe Round, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:golfer_profile) }
    it { is_expected.to belong_to(:course).optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:course_name) }
    it { is_expected.to validate_presence_of(:played_on) }
    it { is_expected.to validate_presence_of(:score) }
    it { is_expected.to validate_inclusion_of(:holes_played).in_array([9, 18]) }
  end

  describe "#calculate_differential" do
    it "calculates differential from score, course rating, and slope" do
      round = build(:round, score: 85, course_rating: 72.5, slope_rating: 130)
      round.valid?
      round.calculate_differential

      # (113 / 130) * (85 - 72.5) = 10.9
      expect(round.differential).to eq(10.9)
    end

    it "does not calculate differential without course rating" do
      round = build(:round, :without_rating)
      round.valid?
      round.calculate_differential

      expect(round.differential).to be_nil
    end
  end

  describe "callbacks" do
    it "updates golfer profile stats after save" do
      profile = create(:golfer_profile)
      create(:round, golfer_profile: profile, score: 80, played_on: 2.days.ago)
      create(:round, golfer_profile: profile, score: 90, played_on: 1.day.ago)

      profile.reload
      expect(profile.total_rounds).to eq(2)
      expect(profile.best_score).to eq(80)
      expect(profile.average_score).to eq(85.0)
      expect(profile.last_played_on).to eq(1.day.ago.to_date)
    end
  end

  describe "scopes" do
    let(:profile) { create(:golfer_profile) }

    it ".for_handicap returns only 18-hole rounds with ratings" do
      eligible = create(:round, golfer_profile: profile)
      create(:round, :nine_holes, golfer_profile: profile)
      create(:round, :without_rating, golfer_profile: profile)

      expect(Round.for_handicap).to contain_exactly(eligible)
    end

    it ".recent returns rounds ordered by played_on desc" do
      old = create(:round, golfer_profile: profile, played_on: 1.month.ago)
      recent = create(:round, golfer_profile: profile, played_on: Date.current)

      expect(Round.recent.first).to eq(recent)
    end
  end
end
