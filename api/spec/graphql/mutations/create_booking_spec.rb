require "rails_helper"

RSpec.describe Mutations::CreateBooking do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.tomorrow) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet) }

  let(:query) do
    <<~GQL
      mutation CreateBooking($teeTimeId: ID!, $playersCount: Int!, $playerNames: [String!]) {
        createBooking(teeTimeId: $teeTimeId, playersCount: $playersCount, playerNames: $playerNames) {
          booking {
            id
            confirmationCode
            status
            playersCount
            totalCents
            teeTime {
              id
              availableSpots
            }
            bookingPlayers {
              name
            }
          }
          errors
        }
      }
    GQL
  end

  describe "createBooking" do
    context "when authenticated with valid params" do
      it "creates a booking" do
        context = graphql_context(user: user)
        result = execute_query(query, variables: {
          teeTimeId: tee_time.id.to_s,
          playersCount: 2,
          playerNames: ["Alice", "Bob"]
        }, context: context)

        data = result.dig("data", "createBooking")
        expect(data["errors"]).to be_empty
        expect(data["booking"]["status"]).to eq("confirmed")
        expect(data["booking"]["playersCount"]).to eq(2)
        expect(data["booking"]["confirmationCode"]).to be_present
        expect(data["booking"]["bookingPlayers"].map { |p| p["name"] }).to contain_exactly("Alice", "Bob")
      end
    end

    context "when not authenticated" do
      it "returns an error" do
        result = execute_query(query, variables: {
          teeTimeId: tee_time.id.to_s,
          playersCount: 2
        }, context: {})

        errors = result["errors"]
        expect(errors).to be_present
        expect(errors.first["message"]).to include("Not authenticated")
      end
    end

    context "when tee time belongs to different organization" do
      let(:other_org) { create(:organization) }
      let(:other_course) { create(:course, organization: other_org) }
      let(:other_sheet) { create(:tee_sheet, course: other_course) }
      let(:other_tee_time) { create(:tee_time, tee_sheet: other_sheet) }

      it "returns not found error" do
        context = graphql_context(user: user)
        expect {
          execute_query(query, variables: {
            teeTimeId: other_tee_time.id.to_s,
            playersCount: 2
          }, context: context)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when tee time is fully booked" do
      let(:tee_time) { create(:tee_time, :fully_booked, tee_sheet: tee_sheet) }

      it "returns errors" do
        context = graphql_context(user: user)
        result = execute_query(query, variables: {
          teeTimeId: tee_time.id.to_s,
          playersCount: 1
        }, context: context)

        data = result.dig("data", "createBooking")
        expect(data["errors"]).not_to be_empty
        expect(data["booking"]).to be_nil
      end
    end
  end
end
