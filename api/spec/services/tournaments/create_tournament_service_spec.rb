require "rails_helper"

RSpec.describe Tournaments::CreateTournamentService do
  let(:org) { create(:organization) }
  let(:course) { create(:course, organization: org) }
  let(:manager) { create(:user, organization: org, role: :manager) }
  let(:golfer) { create(:user, organization: org, role: :golfer) }

  let(:valid_params) do
    {
      organization: org,
      course: course,
      user: manager,
      name: "Spring Classic",
      format: "stroke",
      start_date: 2.weeks.from_now.to_date,
      end_date: 2.weeks.from_now.to_date
    }
  end

  describe ".call" do
    context "with valid params and authorized user" do
      it "creates a tournament in draft status" do
        result = described_class.call(**valid_params)

        expect(result).to be_success
        tournament = result.data.tournament
        expect(tournament.name).to eq("Spring Classic")
        expect(tournament.format).to eq("stroke")
        expect(tournament.status).to eq("draft")
        expect(tournament.organization).to eq(org)
        expect(tournament.course).to eq(course)
        expect(tournament.created_by).to eq(manager)
      end

      it "sets default team_size for individual format" do
        result = described_class.call(**valid_params)
        expect(result.data.tournament.team_size).to eq(1)
      end

      it "sets default team_size for scramble format" do
        result = described_class.call(**valid_params.merge(format: "scramble"))
        expect(result.data.tournament.team_size).to eq(4)
      end
    end

    context "with unauthorized user" do
      it "fails for golfer role" do
        result = described_class.call(**valid_params.merge(user: golfer))
        expect(result).to be_failure
        expect(result.errors.first).to include("permissions")
      end

      it "fails for user from different org" do
        other_org = create(:organization)
        outsider = create(:user, organization: other_org, role: :manager)
        result = described_class.call(**valid_params.merge(user: outsider))
        expect(result).to be_failure
      end
    end

    context "with invalid params" do
      it "fails without name" do
        result = described_class.call(**valid_params.merge(name: nil))
        expect(result).to be_failure
      end

      it "fails without start_date" do
        result = described_class.call(**valid_params.merge(start_date: nil))
        expect(result).to be_failure
      end
    end
  end
end
