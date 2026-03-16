# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeviceToken, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:organization) }
  end

  describe "validations" do
    subject { build(:device_token) }

    it { is_expected.to validate_presence_of(:token) }
    it { is_expected.to validate_uniqueness_of(:token) }
    it { is_expected.to validate_presence_of(:platform) }
  end

  describe "scopes" do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization: organization) }
    let!(:active_token) { create(:device_token, user: user, active: true) }
    let!(:inactive_token) { create(:device_token, user: user, active: false) }

    describe ".active" do
      it "returns only active tokens" do
        expect(described_class.active).to include(active_token)
        expect(described_class.active).not_to include(inactive_token)
      end
    end

    describe ".for_user" do
      let(:other_user) { create(:user, organization: organization) }
      let!(:other_token) { create(:device_token, user: other_user) }

      it "returns tokens for the specified user" do
        expect(described_class.for_user(user)).to include(active_token, inactive_token)
        expect(described_class.for_user(user)).not_to include(other_token)
      end
    end
  end

  describe "#deactivate!" do
    let(:token) { create(:device_token, active: true) }

    it "sets active to false" do
      token.deactivate!
      expect(token.reload.active).to be false
    end
  end

  describe "#touch_last_used!" do
    let(:token) { create(:device_token, last_used_at: 1.day.ago) }

    it "updates last_used_at to current time" do
      freeze_time do
        token.touch_last_used!
        expect(token.reload.last_used_at).to be_within(1.second).of(Time.current)
      end
    end
  end
end
