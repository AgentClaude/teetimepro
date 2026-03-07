require "rails_helper"

RSpec.describe LeaderboardChannel, type: :channel do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tournament) { create(:tournament, :registration_open, organization: organization, course: course) }

  before do
    stub_connection(current_user: user)
  end

  describe "#subscribed" do
    it "subscribes to the tournament leaderboard stream" do
      subscribe(tournament_id: tournament.id)

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("leaderboard_#{tournament.id}")
    end

    it "rejects when tournament does not exist" do
      subscribe(tournament_id: 999_999)

      expect(subscription).to be_rejected
    end
  end
end
