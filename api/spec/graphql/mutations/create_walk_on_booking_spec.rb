require "rails_helper"

RSpec.describe Mutations::CreateWalkOnBooking do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.current) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: 2.hours.from_now, max_players: 4, booked_players: 0, status: :available) }
  let(:pro_shop_user) { create(:user, organization: organization, role: :pro_shop) }
  let(:golfer_user) { create(:user, organization: organization, role: :golfer) }

  let(:mutation) do
    <<~GQL
      mutation CreateWalkOnBooking(
        $teeTimeId: ID
        $courseId: ID
        $playersCount: Int!
        $guestName: String!
        $guestEmail: String
        $guestPhone: String
        $walkOnNotes: String
      ) {
        createWalkOnBooking(
          teeTimeId: $teeTimeId
          courseId: $courseId
          playersCount: $playersCount
          guestName: $guestName
          guestEmail: $guestEmail
          guestPhone: $guestPhone
          walkOnNotes: $walkOnNotes
        ) {
          booking {
            id
            confirmationCode
            bookingType
            guestName
            guestEmail
            guestPhone
            walkOnNotes
            isWalkOn
            playersCount
            status
          }
          teeTime {
            id
          }
          errors
        }
      }
    GQL
  end

  def execute(variables: {}, user: pro_shop_user)
    TeeTimeProSchema.execute(
      mutation,
      variables: variables,
      context: {
        current_user: user,
        current_organization: organization
      }
    )
  end

  context "as pro_shop user with valid params" do
    let(:variables) do
      {
        teeTimeId: tee_time.id.to_s,
        playersCount: 2,
        guestName: "John Walk-In",
        guestEmail: "john@example.com",
        guestPhone: "+15551234567",
        walkOnNotes: "Rental clubs needed"
      }
    end

    it "creates a walk-on booking" do
      result = execute(variables: variables)
      data = result.dig("data", "createWalkOnBooking")

      expect(data["errors"]).to be_empty
      expect(data["booking"]["bookingType"]).to eq("walk_on")
      expect(data["booking"]["guestName"]).to eq("John Walk-In")
      expect(data["booking"]["isWalkOn"]).to be true
      expect(data["booking"]["playersCount"]).to eq(2)
      expect(data["booking"]["status"]).to eq("confirmed")
    end
  end

  context "as golfer (insufficient role)" do
    let(:variables) do
      {
        teeTimeId: tee_time.id.to_s,
        playersCount: 1,
        guestName: "Sneaky Guest"
      }
    end

    it "raises authorization error" do
      result = execute(variables: variables, user: golfer_user)
      expect(result["errors"]).to be_present
      expect(result["errors"].first["message"]).to match(/permissions/i)
    end
  end

  context "without authentication" do
    let(:variables) do
      {
        teeTimeId: tee_time.id.to_s,
        playersCount: 1,
        guestName: "Anon Guest"
      }
    end

    it "raises authentication error" do
      result = execute(variables: variables, user: nil)
      expect(result["errors"]).to be_present
      expect(result["errors"].first["message"]).to match(/authenticated/i)
    end
  end
end
