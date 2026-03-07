require "rails_helper"

RSpec.describe HandicapRevision, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:golfer_profile) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:handicap_index) }
    it { is_expected.to validate_presence_of(:effective_date) }
    it { is_expected.to validate_presence_of(:source) }
    it { is_expected.to validate_inclusion_of(:source).in_array(%w[calculated manual imported]) }
  end

  describe "scopes" do
    let(:profile) { create(:golfer_profile) }

    it ".recent returns revisions ordered by effective_date desc" do
      old = create(:handicap_revision, golfer_profile: profile, effective_date: 6.months.ago)
      recent = create(:handicap_revision, golfer_profile: profile, effective_date: Date.current)

      expect(HandicapRevision.recent.first).to eq(recent)
    end

    it ".for_period returns revisions within date range" do
      in_range = create(:handicap_revision, golfer_profile: profile, effective_date: 1.month.ago)
      out_of_range = create(:handicap_revision, golfer_profile: profile, effective_date: 1.year.ago)

      results = HandicapRevision.for_period(2.months.ago, Date.current)
      expect(results).to include(in_range)
      expect(results).not_to include(out_of_range)
    end
  end
end
