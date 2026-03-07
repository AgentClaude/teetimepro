require "rails_helper"

RSpec.describe GolferSegment, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:created_by).class_name("User") }
    it { is_expected.to have_many(:golfer_segment_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:members).through(:golfer_segment_memberships) }
  end

  describe "validations" do
    subject { build(:golfer_segment) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:organization_id) }
    it { is_expected.to validate_presence_of(:filter_criteria) }

    it "rejects unknown filter keys" do
      segment = build(:golfer_segment, filter_criteria: { "bogus_key" => 1 })
      expect(segment).not_to be_valid
      expect(segment.errors[:filter_criteria]).to include(/unknown keys/)
    end

    it "accepts valid filter keys" do
      segment = build(:golfer_segment, filter_criteria: {
        "booking_count_min" => 5,
        "membership_status" => "active",
        "total_spent_min" => 10000
      })
      expect(segment).to be_valid
    end
  end

  describe "scopes" do
    let(:org) { create(:organization) }
    let(:manager) { create(:user, :manager, organization: org) }

    it ".by_organization returns segments for org" do
      seg = create(:golfer_segment, organization: org, created_by: manager)
      other_org = create(:organization)
      other_manager = create(:user, :manager, organization: other_org)
      create(:golfer_segment, organization: other_org, created_by: other_manager)

      expect(GolferSegment.by_organization(org)).to eq([seg])
    end

    it ".dynamic returns only dynamic segments" do
      dynamic = create(:golfer_segment, organization: org, created_by: manager, is_dynamic: true)
      create(:golfer_segment, :static, organization: org, created_by: manager, name: "Static")

      expect(GolferSegment.dynamic).to eq([dynamic])
    end
  end
end
