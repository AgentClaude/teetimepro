# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::SeedBookingTemplatesService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization, role: :manager) }

  describe ".call" do
    it "creates both booking templates" do
      result = described_class.call(organization: organization, user: user)

      expect(result).to be_success
      expect(result.data[:created]).to contain_exactly("booking_confirmation", "booking_cancellation")
      expect(result.data[:skipped]).to be_empty
    end

    it "creates templates with correct attributes" do
      described_class.call(organization: organization, user: user)

      confirmation = organization.email_templates.find_by(name: "booking_confirmation")
      expect(confirmation).to be_present
      expect(confirmation.category).to eq("transactional")
      expect(confirmation.subject).to include("{{course_name}}")
      expect(confirmation.body_html).to include("{{first_name}}")
      expect(confirmation.body_html).to include("{{confirmation_code}}")
      expect(confirmation.created_by).to eq(user)

      cancellation = organization.email_templates.find_by(name: "booking_cancellation")
      expect(cancellation).to be_present
      expect(cancellation.category).to eq("transactional")
    end

    it "skips existing templates" do
      # First call creates them
      described_class.call(organization: organization, user: user)

      # Second call skips them
      result = described_class.call(organization: organization, user: user)
      expect(result).to be_success
      expect(result.data[:created]).to be_empty
      expect(result.data[:skipped]).to contain_exactly("booking_confirmation", "booking_cancellation")
    end

    it "includes booking-specific merge fields" do
      described_class.call(organization: organization, user: user)

      template = organization.email_templates.find_by(name: "booking_confirmation")
      expect(template.merge_fields).to include("{{course_name}}")
      expect(template.merge_fields).to include("{{tee_time}}")
      expect(template.merge_fields).to include("{{confirmation_code}}")
      expect(template.merge_fields).to include("{{players_count}}")
    end

    it "requires organization" do
      result = described_class.call(organization: nil, user: user)
      expect(result).not_to be_success
    end

    it "requires user" do
      result = described_class.call(organization: organization, user: nil)
      expect(result).not_to be_success
    end
  end
end
