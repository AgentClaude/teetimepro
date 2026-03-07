# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmailTemplate, type: :model do
  describe "validations" do
    subject { build(:email_template) }

    it { is_expected.to be_valid }

    it "requires name" do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it "requires subject" do
      subject.subject = nil
      expect(subject).not_to be_valid
    end

    it "requires body_html" do
      subject.body_html = nil
      expect(subject).not_to be_valid
    end

    it "validates category inclusion" do
      subject.category = "invalid"
      expect(subject).not_to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:created_by) }
  end

  describe "#render_html" do
    let(:template) do
      build(:email_template,
        body_html: "<p>Hello {{first_name}} {{last_name}}, welcome to {{organization_name}}!</p>"
      )
    end

    it "replaces merge fields with values" do
      result = template.render_html(
        "first_name" => "John",
        "last_name" => "Doe",
        "organization_name" => "Pine Valley GC"
      )
      expect(result).to eq("<p>Hello John Doe, welcome to Pine Valley GC!</p>")
    end

    it "leaves unreplaced merge fields as-is" do
      result = template.render_html("first_name" => "John")
      expect(result).to include("{{last_name}}")
    end
  end

  describe "#render_subject" do
    let(:template) do
      build(:email_template, subject: "Hey {{first_name}}, special offer!")
    end

    it "replaces merge fields in subject" do
      result = template.render_subject("first_name" => "Jane")
      expect(result).to eq("Hey Jane, special offer!")
    end
  end

  describe "#increment_usage!" do
    it "increments the usage counter" do
      template = create(:email_template, usage_count: 5)
      template.increment_usage!
      expect(template.reload.usage_count).to eq(6)
    end
  end

  describe "scopes" do
    let(:org) { create(:organization) }
    let(:user) { create(:user, organization: org) }

    it ".active returns only active templates" do
      active = create(:email_template, organization: org, created_by: user)
      create(:email_template, :inactive, organization: org, created_by: user)
      expect(EmailTemplate.active).to contain_exactly(active)
    end

    it ".by_category filters by category" do
      promo = create(:email_template, :promotion, organization: org, created_by: user)
      create(:email_template, :newsletter, organization: org, created_by: user)
      expect(EmailTemplate.by_category("promotion")).to contain_exactly(promo)
    end
  end
end
