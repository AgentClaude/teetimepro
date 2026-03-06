require "rails_helper"

RSpec.describe GenerateDailyTeeSheetJob do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }

  describe "#perform" do
    it "generates tee sheets for the next 7 days" do
      expect {
        described_class.new.perform
      }.to change(TeeSheet, :count).by(7)
    end

    it "generates tee sheets for multiple courses" do
      course_2 = create(:course, organization: organization)

      expect {
        described_class.new.perform
      }.to change(TeeSheet, :count).by(14)
    end

    it "skips dates that already have tee sheets" do
      # Pre-create a tee sheet for today
      TeeSheets::GenerateTeeSheetService.call(course: course, date: Date.current)

      expect {
        described_class.new.perform
      }.to change(TeeSheet, :count).by(6) # 7 - 1 already existing
    end

    it "is idempotent when run multiple times" do
      described_class.new.perform

      expect {
        described_class.new.perform
      }.not_to change(TeeSheet, :count)
    end
  end
end
