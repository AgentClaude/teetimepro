require "rails_helper"

RSpec.describe Tournaments::UpdateTournamentService do
  let(:org) { create(:organization) }
  let(:course) { create(:course, organization: org) }
  let(:manager) { create(:user, organization: org, role: :manager) }
  let(:tournament) { create(:tournament, organization: org, course: course, created_by: manager) }

  describe ".call" do
    it "updates basic attributes" do
      result = described_class.call(
        tournament: tournament,
        user: manager,
        attributes: { name: "Updated Name", description: "New desc" }
      )

      expect(result).to be_success
      expect(result.data.tournament.name).to eq("Updated Name")
      expect(result.data.tournament.description).to eq("New desc")
    end

    context "status transitions" do
      it "allows draft -> registration_open" do
        result = described_class.call(
          tournament: tournament,
          user: manager,
          attributes: { status: "registration_open" }
        )
        expect(result).to be_success
        expect(result.data.tournament.status).to eq("registration_open")
      end

      it "rejects invalid transitions" do
        result = described_class.call(
          tournament: tournament,
          user: manager,
          attributes: { status: "completed" }
        )
        expect(result).to be_failure
        expect(result.errors.first).to include("Cannot transition")
      end

      it "prevents transition from completed" do
        tournament.update!(status: :completed, start_date: 1.week.ago, end_date: 1.week.ago)
        result = described_class.call(
          tournament: tournament,
          user: manager,
          attributes: { status: "draft" }
        )
        expect(result).to be_failure
      end
    end

    context "format change with active entries" do
      it "prevents format change when participants exist" do
        tournament.update!(status: :registration_open, registration_opens_at: 1.week.ago, registration_closes_at: 1.week.from_now)
        create(:tournament_entry, tournament: tournament, user: create(:user, organization: org))

        result = described_class.call(
          tournament: tournament,
          user: manager,
          attributes: { format: "scramble" }
        )
        expect(result).to be_failure
        expect(result.errors.first).to include("Cannot change format")
      end
    end
  end
end
