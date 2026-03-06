require "rails_helper"

RSpec.describe ApplicationPolicy do
  let(:organization) { create(:organization) }
  let(:other_org) { create(:organization) }

  let(:owner) { create(:user, :owner, organization: organization) }
  let(:admin) { create(:user, :admin, organization: organization) }
  let(:manager) { create(:user, :manager, organization: organization) }
  let(:pro_shop) { create(:user, :pro_shop, organization: organization) }
  let(:staff) { create(:user, :staff, organization: organization) }
  let(:golfer) { create(:user, organization: organization) }

  let(:course) { create(:course, organization: organization) }
  let(:other_course) { create(:course, organization: other_org) }

  describe "#same_organization?" do
    it "returns true when record belongs to user's org" do
      policy = described_class.new(golfer, course)
      expect(policy.send(:same_organization?)).to be true
    end

    it "returns false when record belongs to different org" do
      policy = described_class.new(golfer, other_course)
      expect(policy.send(:same_organization?)).to be false
    end
  end

  describe "role hierarchy" do
    context "update? (requires manager+)" do
      it "allows owner" do
        expect(described_class.new(owner, course).update?).to be true
      end

      it "allows admin" do
        expect(described_class.new(admin, course).update?).to be true
      end

      it "allows manager" do
        expect(described_class.new(manager, course).update?).to be true
      end

      it "denies pro_shop" do
        expect(described_class.new(pro_shop, course).update?).to be false
      end

      it "denies staff" do
        expect(described_class.new(staff, course).update?).to be false
      end

      it "denies golfer" do
        expect(described_class.new(golfer, course).update?).to be false
      end
    end

    context "destroy? (requires admin+)" do
      it "allows owner" do
        expect(described_class.new(owner, course).destroy?).to be true
      end

      it "allows admin" do
        expect(described_class.new(admin, course).destroy?).to be true
      end

      it "denies manager" do
        expect(described_class.new(manager, course).destroy?).to be false
      end
    end
  end
end
