require "rails_helper"

RSpec.describe Marketplace::ConnectService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }

  describe ".call" do
    context "with valid params" do
      it "creates a marketplace connection" do
        result = described_class.call(
          organization: organization,
          course: course,
          provider: "golfnow",
          credentials: { "api_key" => "test_key" }
        )

        expect(result).to be_success
        connection = result.data[:connection]
        expect(connection).to be_persisted
        expect(connection.provider).to eq("golfnow")
        expect(connection.organization).to eq(organization)
        expect(connection.course).to eq(course)
      end
    end

    context "with invalid provider" do
      it "returns failure" do
        result = described_class.call(
          organization: organization,
          course: course,
          provider: "invalid_provider",
          credentials: { "api_key" => "test" }
        )

        expect(result).not_to be_success
      end
    end

    context "when course doesn't belong to org" do
      let(:other_org) { create(:organization) }
      let(:other_course) { create(:course, organization: other_org) }

      it "returns failure" do
        result = described_class.call(
          organization: organization,
          course: other_course,
          provider: "golfnow",
          credentials: { "api_key" => "test" }
        )

        expect(result).not_to be_success
        expect(result.errors).to include("Course does not belong to this organization")
      end
    end

    context "when duplicate connection exists" do
      before do
        create(:marketplace_connection, organization: organization, course: course, provider: "golfnow")
      end

      it "returns validation failure" do
        result = described_class.call(
          organization: organization,
          course: course,
          provider: "golfnow",
          credentials: { "api_key" => "test" }
        )

        expect(result).not_to be_success
      end
    end

    context "with missing params" do
      it "returns validation failure without organization" do
        result = described_class.call(
          organization: nil,
          course: course,
          provider: "golfnow"
        )

        expect(result).not_to be_success
      end
    end
  end
end
