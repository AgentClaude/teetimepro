require "rails_helper"

RSpec.describe Authorization::RoleCheckService do
  let(:organization) { create(:organization) }

  let(:owner) { create(:user, :owner, organization: organization) }
  let(:admin) { create(:user, :admin, organization: organization) }
  let(:manager) { create(:user, :manager, organization: organization) }
  let(:pro_shop) { create(:user, :pro_shop, organization: organization) }
  let(:staff) { create(:user, :staff, organization: organization) }
  let(:golfer) { create(:user, organization: organization) }

  describe ".call" do
    context "manage_courses (requires manager)" do
      it "allows owner" do
        result = described_class.call(user: owner, permission: :manage_courses)
        expect(result).to be_success
      end

      it "allows manager" do
        result = described_class.call(user: manager, permission: :manage_courses)
        expect(result).to be_success
      end

      it "denies pro_shop" do
        result = described_class.call(user: pro_shop, permission: :manage_courses)
        expect(result).to be_failure
      end

      it "denies golfer" do
        result = described_class.call(user: golfer, permission: :manage_courses)
        expect(result).to be_failure
      end
    end

    context "check_in (requires staff)" do
      it "allows staff" do
        result = described_class.call(user: staff, permission: :check_in)
        expect(result).to be_success
      end

      it "allows pro_shop" do
        result = described_class.call(user: pro_shop, permission: :check_in)
        expect(result).to be_success
      end

      it "denies golfer" do
        result = described_class.call(user: golfer, permission: :check_in)
        expect(result).to be_failure
      end
    end

    context "manage_organization (requires owner)" do
      it "allows owner" do
        result = described_class.call(user: owner, permission: :manage_organization)
        expect(result).to be_success
      end

      it "denies admin" do
        result = described_class.call(user: admin, permission: :manage_organization)
        expect(result).to be_failure
      end
    end

    context "create_booking (requires golfer)" do
      it "allows any authenticated user" do
        result = described_class.call(user: golfer, permission: :create_booking)
        expect(result).to be_success
      end
    end

    context "unknown permission" do
      it "returns failure" do
        result = described_class.call(user: owner, permission: :fly_to_moon)
        expect(result).to be_failure
        expect(result.error_message).to match(/Unknown permission/)
      end
    end

    context "missing user" do
      it "returns validation failure" do
        result = described_class.call(user: nil, permission: :manage_courses)
        expect(result).to be_failure
      end
    end
  end
end
