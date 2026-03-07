require "rails_helper"

RSpec.describe Mutations::RecordTournamentScore do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization, role: :staff) }
  let(:course) { create(:course, organization: organization) }
  let(:tournament) do
    create(:tournament, :registration_open, organization: organization, course: course)
  end
  let(:entry_user) { create(:user, organization: organization) }
  let(:entry) { create(:tournament_entry, tournament: tournament, user: entry_user) }
  let(:round) { create(:tournament_round, :in_progress, tournament: tournament) }

  before do
    entry
    tournament.update_column(:status, Tournament.statuses[:in_progress])
    tournament.reload
  end

  let(:query) do
    <<~GQL
      mutation RecordTournamentScore(
        $tournamentId: ID!
        $tournamentEntryId: ID!
        $roundId: ID!
        $holeNumber: Int!
        $strokes: Int!
        $par: Int!
        $putts: Int
        $fairwayHit: Boolean
        $greenInRegulation: Boolean
      ) {
        recordTournamentScore(
          tournamentId: $tournamentId
          tournamentEntryId: $tournamentEntryId
          roundId: $roundId
          holeNumber: $holeNumber
          strokes: $strokes
          par: $par
          putts: $putts
          fairwayHit: $fairwayHit
          greenInRegulation: $greenInRegulation
        ) {
          score {
            id
            holeNumber
            strokes
            par
            scoreToPar
            scoreLabel
          }
          errors
        }
      }
    GQL
  end

  let(:variables) do
    {
      tournamentId: tournament.id.to_s,
      tournamentEntryId: entry.id.to_s,
      roundId: round.id.to_s,
      holeNumber: 1,
      strokes: 4,
      par: 4,
      putts: 2,
      fairwayHit: true,
      greenInRegulation: true
    }
  end

  def execute_query
    TeeTimeProSchema.execute(
      query,
      variables: variables,
      context: {
        current_user: user,
        current_organization: organization
      }
    )
  end

  it "records a score successfully" do
    result = execute_query
    data = result.dig("data", "recordTournamentScore")

    expect(data["errors"]).to be_empty
    expect(data["score"]["holeNumber"]).to eq(1)
    expect(data["score"]["strokes"]).to eq(4)
    expect(data["score"]["par"]).to eq(4)
    expect(data["score"]["scoreToPar"]).to eq(0)
    expect(data["score"]["scoreLabel"]).to eq("par")
  end

  it "records a birdie" do
    variables[:strokes] = 3
    result = execute_query
    data = result.dig("data", "recordTournamentScore")

    expect(data["errors"]).to be_empty
    expect(data["score"]["scoreToPar"]).to eq(-1)
    expect(data["score"]["scoreLabel"]).to eq("birdie")
  end

  it "requires staff role" do
    viewer = create(:user, organization: organization, role: :viewer)
    result = TeeTimeProSchema.execute(
      query,
      variables: variables,
      context: {
        current_user: viewer,
        current_organization: organization
      }
    )

    expect(result["errors"]).to be_present
  end
end
