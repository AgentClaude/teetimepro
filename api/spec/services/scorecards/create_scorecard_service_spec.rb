require "rails_helper"

RSpec.describe Scorecards::CreateScorecardService do
  let(:organization) { create(:organization) }
  let(:golfer_profile) { create(:golfer_profile) }
  let(:course) { create(:course, organization: organization) }

  describe ".call" do
    context "with valid params" do
      it "creates a scorecard successfully" do
        result = described_class.call(
          golfer_profile: golfer_profile,
          course: course,
          played_on: Date.current
        )

        expect(result).to be_success
        expect(result.scorecard).to be_a(Scorecard)
        expect(result.scorecard.status).to eq("in_progress")
        expect(result.scorecard.holes_played).to eq(18)
      end

      it "pre-populates hole scores" do
        result = described_class.call(
          golfer_profile: golfer_profile,
          course: course,
          played_on: Date.current
        )

        expect(result.scorecard.hole_scores.count).to eq(18)
        expect(result.scorecard.hole_scores.map(&:hole_number)).to eq((1..18).to_a)
      end

      it "creates 9-hole scorecard" do
        result = described_class.call(
          golfer_profile: golfer_profile,
          course: course,
          played_on: Date.current,
          holes_played: 9
        )

        expect(result).to be_success
        expect(result.scorecard.holes_played).to eq(9)
        expect(result.scorecard.hole_scores.count).to eq(9)
      end

      it "sets optional fields" do
        result = described_class.call(
          golfer_profile: golfer_profile,
          course: course,
          played_on: Date.current,
          tee_color: "blue",
          course_rating: 72.1,
          slope_rating: 131,
          notes: "Tournament round"
        )

        expect(result.scorecard.tee_color).to eq("blue")
        expect(result.scorecard.course_rating).to eq(72.1)
        expect(result.scorecard.slope_rating).to eq(131)
        expect(result.scorecard.notes).to eq("Tournament round")
      end
    end

    context "with course hole configuration" do
      before do
        (1..18).each do |n|
          create(:course_hole, course: course, hole_number: n, par: n % 3 == 0 ? 3 : (n % 5 == 0 ? 5 : 4))
        end
      end

      it "uses course hole pars" do
        result = described_class.call(
          golfer_profile: golfer_profile,
          course: course,
          played_on: Date.current
        )

        course_pars = course.course_holes.ordered.pluck(:par)
        scorecard_pars = result.scorecard.hole_scores.order(:hole_number).pluck(:par)
        expect(scorecard_pars).to eq(course_pars)
      end
    end

    context "with missing required params" do
      it "fails without golfer_profile" do
        result = described_class.call(
          golfer_profile: nil,
          course: course,
          played_on: Date.current
        )

        expect(result).to be_failure
      end

      it "fails without course" do
        result = described_class.call(
          golfer_profile: golfer_profile,
          course: nil,
          played_on: Date.current
        )

        expect(result).to be_failure
      end

      it "fails without played_on" do
        result = described_class.call(
          golfer_profile: golfer_profile,
          course: course,
          played_on: nil
        )

        expect(result).to be_failure
      end
    end
  end
end
