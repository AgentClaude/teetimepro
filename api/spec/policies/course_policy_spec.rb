require "rails_helper"

RSpec.describe CoursePolicy do
  let(:organization) { create(:organization) }
  let(:other_org) { create(:organization) }
  let(:course) { create(:course, organization: organization) }

  let(:owner) { create(:user, :owner, organization: organization) }
  let(:admin) { create(:user, :admin, organization: organization) }
  let(:manager) { create(:user, :manager, organization: organization) }
  let(:pro_shop) { create(:user, :pro_shop, organization: organization) }
  let(:staff) { create(:user, :staff, organization: organization) }
  let(:golfer) { create(:user, organization: organization) }

  describe "#show?" do
    it "allows any user in the same org" do
      expect(described_class.new(golfer, course).show?).to be true
    end

    it "denies users from other orgs" do
      other_user = create(:user, organization: other_org)
      expect(described_class.new(other_user, course).show?).to be false
    end
  end

  describe "#create?" do
    it "allows manager" do
      expect(described_class.new(manager, course).create?).to be true
    end

    it "allows admin" do
      expect(described_class.new(admin, course).create?).to be true
    end

    it "allows owner" do
      expect(described_class.new(owner, course).create?).to be true
    end

    it "denies pro_shop" do
      expect(described_class.new(pro_shop, course).create?).to be false
    end

    it "denies staff" do
      expect(described_class.new(staff, course).create?).to be false
    end

    it "denies golfer" do
      expect(described_class.new(golfer, course).create?).to be false
    end
  end

  describe "#destroy?" do
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

  describe "#manage_tee_sheets?" do
    it "allows manager+" do
      expect(described_class.new(manager, course).manage_tee_sheets?).to be true
      expect(described_class.new(admin, course).manage_tee_sheets?).to be true
      expect(described_class.new(owner, course).manage_tee_sheets?).to be true
    end

    it "denies pro_shop and below" do
      expect(described_class.new(pro_shop, course).manage_tee_sheets?).to be false
      expect(described_class.new(staff, course).manage_tee_sheets?).to be false
      expect(described_class.new(golfer, course).manage_tee_sheets?).to be false
    end
  end

  describe "Scope" do
    let!(:org_course) { create(:course, organization: organization) }
    let!(:other_course) { create(:course, organization: other_org) }

    it "returns only courses for the user's organization" do
      scope = described_class::Scope.new(golfer, Course).resolve
      expect(scope).to include(org_course)
      expect(scope).not_to include(other_course)
    end
  end
end
