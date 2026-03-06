require "rails_helper"

RSpec.describe BookingPolicy do
  let(:organization) { create(:organization) }
  let(:other_org) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet) }

  let(:owner) { create(:user, :owner, organization: organization) }
  let(:admin) { create(:user, :admin, organization: organization) }
  let(:manager) { create(:user, :manager, organization: organization) }
  let(:pro_shop) { create(:user, :pro_shop, organization: organization) }
  let(:staff) { create(:user, :staff, organization: organization) }
  let(:golfer) { create(:user, organization: organization) }
  let(:other_golfer) { create(:user, organization: organization) }

  let(:booking) { create(:booking, tee_time: tee_time, user: golfer) }

  describe "#show?" do
    it "allows the booking owner" do
      expect(described_class.new(golfer, booking).show?).to be true
    end

    it "allows staff" do
      expect(described_class.new(staff, booking).show?).to be true
    end

    it "allows pro_shop" do
      expect(described_class.new(pro_shop, booking).show?).to be true
    end

    it "denies other golfers" do
      expect(described_class.new(other_golfer, booking).show?).to be false
    end

    it "denies users from other orgs" do
      other_user = create(:user, :admin, organization: other_org)
      expect(described_class.new(other_user, booking).show?).to be false
    end
  end

  describe "#create?" do
    it "allows any user in the same org" do
      expect(described_class.new(golfer, booking).create?).to be true
    end

    it "denies users from other orgs" do
      other_user = create(:user, organization: other_org)
      expect(described_class.new(other_user, booking).create?).to be false
    end
  end

  describe "#cancel?" do
    it "allows the booking owner to cancel own booking" do
      expect(described_class.new(golfer, booking).cancel?).to be true
    end

    it "allows pro_shop to cancel any booking" do
      expect(described_class.new(pro_shop, booking).cancel?).to be true
    end

    it "allows manager to cancel any booking" do
      expect(described_class.new(manager, booking).cancel?).to be true
    end

    it "denies other golfers from cancelling" do
      expect(described_class.new(other_golfer, booking).cancel?).to be false
    end

    it "denies staff from cancelling others' bookings" do
      expect(described_class.new(staff, booking).cancel?).to be false
    end
  end

  describe "#check_in?" do
    it "allows staff" do
      expect(described_class.new(staff, booking).check_in?).to be true
    end

    it "allows pro_shop" do
      expect(described_class.new(pro_shop, booking).check_in?).to be true
    end

    it "allows manager" do
      expect(described_class.new(manager, booking).check_in?).to be true
    end

    it "denies golfers" do
      expect(described_class.new(golfer, booking).check_in?).to be false
    end
  end

  describe "#walk_on?" do
    it "allows pro_shop" do
      expect(described_class.new(pro_shop, booking).walk_on?).to be true
    end

    it "allows manager" do
      expect(described_class.new(manager, booking).walk_on?).to be true
    end

    it "denies staff" do
      expect(described_class.new(staff, booking).walk_on?).to be false
    end

    it "denies golfers" do
      expect(described_class.new(golfer, booking).walk_on?).to be false
    end
  end

  describe "Scope" do
    let!(:golfer_booking) { create(:booking, tee_time: tee_time, user: golfer) }
    let!(:other_booking) { create(:booking, tee_time: tee_time, user: other_golfer) }

    it "shows all org bookings to staff+" do
      scope = described_class::Scope.new(staff, Booking).resolve
      expect(scope).to include(golfer_booking, other_booking)
    end

    it "shows only own bookings to golfers" do
      scope = described_class::Scope.new(golfer, Booking).resolve
      expect(scope).to include(golfer_booking)
      expect(scope).not_to include(other_booking)
    end
  end
end
