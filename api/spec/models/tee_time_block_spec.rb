# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeeTimeBlock, type: :model do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:user) { create(:user, organization: organization) }

  describe "validations" do
    subject { build(:tee_time_block, organization: organization, course: course, created_by: user) }

    it { is_expected.to validate_presence_of(:reason) }
    it { is_expected.to validate_presence_of(:starts_at) }
    it { is_expected.to validate_presence_of(:ends_at) }
    it { is_expected.to validate_length_of(:reason).is_at_most(255) }
    it { is_expected.to validate_length_of(:description).is_at_most(2000) }

    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is invalid when ends_at is before starts_at" do
      subject.ends_at = subject.starts_at - 1.hour
      expect(subject).not_to be_valid
      expect(subject.errors[:ends_at]).to include("must be after start time")
    end

    it "is invalid when course belongs to different organization" do
      other_org = create(:organization)
      other_course = create(:course, organization: other_org)
      subject.course = other_course
      expect(subject).not_to be_valid
      expect(subject.errors[:course]).to include("must belong to the organization")
    end
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:block_type).with_values(maintenance: 0, event: 1, weather: 2, other: 3) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:course) }
    it { is_expected.to belong_to(:created_by).class_name("User") }
    it { is_expected.to have_many(:tee_times).dependent(:nullify) }
  end

  describe "scopes" do
    let!(:active_block) { create(:tee_time_block, :future, organization: organization, course: course, created_by: user) }
    let!(:inactive_block) { create(:tee_time_block, :inactive, :future, organization: organization, course: course, created_by: user, starts_at: 3.days.from_now, ends_at: 4.days.from_now) }
    let!(:past_block) { create(:tee_time_block, :past, organization: organization, course: course, created_by: user) }

    describe ".active" do
      it "returns only active blocks" do
        expect(TeeTimeBlock.active).to include(active_block)
        expect(TeeTimeBlock.active).not_to include(inactive_block)
      end
    end

    describe ".current" do
      let!(:current_block) { create(:tee_time_block, :current, organization: organization, course: course, created_by: user) }

      it "returns active blocks with future end times" do
        expect(TeeTimeBlock.current).to include(current_block)
        expect(TeeTimeBlock.current).to include(active_block)
        expect(TeeTimeBlock.current).not_to include(past_block)
      end
    end
  end

  describe "#duration_minutes" do
    it "calculates duration in minutes" do
      block = build(:tee_time_block, starts_at: Time.current, ends_at: 2.hours.from_now)
      expect(block.duration_minutes).to eq(120)
    end
  end

  describe "#currently_active?" do
    it "returns true when block is active and current time is in range" do
      block = build(:tee_time_block, :current)
      expect(block.currently_active?).to be true
    end

    it "returns false when block is inactive" do
      block = build(:tee_time_block, :current, :inactive)
      expect(block.currently_active?).to be false
    end

    it "returns false when block is in the future" do
      block = build(:tee_time_block, :future)
      expect(block.currently_active?).to be false
    end
  end
end
