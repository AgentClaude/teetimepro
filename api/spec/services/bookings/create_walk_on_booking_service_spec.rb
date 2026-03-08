require "rails_helper"

RSpec.describe Bookings::CreateWalkOnBookingService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.current) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: 2.hours.from_now, max_players: 4, booked_players: 0, status: :available) }
  let(:pro_shop_user) { create(:user, organization: organization, role: :pro_shop) }
  let(:golfer_user) { create(:user, organization: organization, role: :golfer) }

  describe ".call" do
    context "with valid params and specific tee time" do
      subject do
        described_class.call(
          organization: organization,
          staff_user: pro_shop_user,
          tee_time_id: tee_time.id,
          players_count: 2,
          guest_name: "John Walk-In",
          guest_email: "john@example.com",
          guest_phone: "+15551234567",
          walk_on_notes: "Needs rental clubs"
        )
      end

      it "creates a walk-on booking" do
        expect { subject }.to change(Booking, :count).by(1)
      end

      it "returns success" do
        expect(subject).to be_success
      end

      it "sets booking_type to walk_on" do
        result = subject
        expect(result.data.booking.booking_type).to eq("walk_on")
      end

      it "stores guest information" do
        result = subject
        booking = result.data.booking
        expect(booking.guest_name).to eq("John Walk-In")
        expect(booking.guest_email).to eq("john@example.com")
        expect(booking.guest_phone).to eq("+15551234567")
      end

      it "records the staff member who created it" do
        result = subject
        expect(result.data.booking.created_by).to eq(pro_shop_user)
      end

      it "creates booking players" do
        result = subject
        expect(result.data.booking.booking_players.count).to eq(2)
        expect(result.data.booking.booking_players.first.name).to eq("John Walk-In")
      end

      it "books spots on the tee time" do
        subject
        expect(tee_time.reload.booked_players).to eq(2)
      end

      it "stores walk-on notes" do
        result = subject
        expect(result.data.booking.walk_on_notes).to eq("Needs rental clubs")
      end
    end

    context "with auto-assign (course_id instead of tee_time_id)" do
      let!(:earlier_tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: 1.hour.from_now, max_players: 4, booked_players: 0, status: :available) }
      let!(:later_tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: 3.hours.from_now, max_players: 4, booked_players: 0, status: :available) }

      subject do
        described_class.call(
          organization: organization,
          staff_user: pro_shop_user,
          course_id: course.id,
          players_count: 2,
          guest_name: "Jane Walk-In"
        )
      end

      it "assigns the next available tee time" do
        result = subject
        expect(result.data.tee_time).to eq(earlier_tee_time)
      end

      it "returns success" do
        expect(subject).to be_success
      end
    end

    context "when no tee times are available" do
      let!(:full_tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: 1.hour.from_now, max_players: 4, booked_players: 4, status: :fully_booked) }

      subject do
        described_class.call(
          organization: organization,
          staff_user: pro_shop_user,
          course_id: course.id,
          players_count: 2,
          guest_name: "No Luck Larry"
        )
      end

      it "returns failure" do
        expect(subject).not_to be_success
      end

      it "returns descriptive error" do
        expect(subject.errors).to include(match(/No available tee times/))
      end
    end

    context "when not enough spots" do
      let(:almost_full) { create(:tee_time, tee_sheet: tee_sheet, starts_at: 2.hours.from_now, max_players: 4, booked_players: 3, status: :partially_booked) }

      subject do
        described_class.call(
          organization: organization,
          staff_user: pro_shop_user,
          tee_time_id: almost_full.id,
          players_count: 3,
          guest_name: "Too Many Mike"
        )
      end

      it "returns failure" do
        expect(subject).not_to be_success
      end

      it "includes spots remaining in error" do
        expect(subject.errors).to include(match(/1 spot\(s\) remaining/))
      end
    end

    context "with insufficient role" do
      subject do
        described_class.call(
          organization: organization,
          staff_user: golfer_user,
          tee_time_id: tee_time.id,
          players_count: 1,
          guest_name: "Unauthorized Guest"
        )
      end

      it "returns failure" do
        expect(subject).not_to be_success
      end

      it "includes permission error" do
        expect(subject.errors).to include(match(/permission/))
      end
    end

    context "with missing guest name" do
      subject do
        described_class.call(
          organization: organization,
          staff_user: pro_shop_user,
          tee_time_id: tee_time.id,
          players_count: 1,
          guest_name: nil
        )
      end

      it "returns failure" do
        expect(subject).not_to be_success
      end
    end

    context "with existing user_id" do
      let(:existing_golfer) { create(:user, organization: organization, role: :golfer) }

      subject do
        described_class.call(
          organization: organization,
          staff_user: pro_shop_user,
          tee_time_id: tee_time.id,
          players_count: 1,
          guest_name: existing_golfer.full_name,
          user_id: existing_golfer.id
        )
      end

      it "assigns the booking to the existing user" do
        result = subject
        expect(result.data.booking.user).to eq(existing_golfer)
      end
    end

    context "without tee_time_id or course_id" do
      subject do
        described_class.call(
          organization: organization,
          staff_user: pro_shop_user,
          players_count: 1,
          guest_name: "Lost Larry"
        )
      end

      it "returns validation failure" do
        expect(subject).not_to be_success
      end
    end
  end
end
