require "rails_helper"

RSpec.describe CalendarConnection, type: :model do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }

  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:calendar_connection, user: user) }

    it { should validate_inclusion_of(:provider).in_array(%w[google apple]) }
    it { should validate_uniqueness_of(:provider).scoped_to(:user_id) }

    context "when enabled" do
      it "validates presence of access_token" do
        connection = build(:calendar_connection, user: user, enabled: true, access_token: nil)
        expect(connection).not_to be_valid
        expect(connection.errors[:access_token]).to include("can't be blank")
      end
    end

    context "when disabled" do
      it "does not require access_token" do
        connection = build(:calendar_connection, user: user, enabled: false, access_token: nil)
        expect(connection).to be_valid
      end
    end
  end

  describe "scopes" do
    let!(:enabled_google) { create(:calendar_connection, user: user, provider: "google", enabled: true) }
    let!(:disabled_google) { create(:calendar_connection, :disabled, user: user, provider: "apple", enabled: false) }

    describe ".enabled" do
      it "returns only enabled connections" do
        expect(CalendarConnection.enabled).to contain_exactly(enabled_google)
      end
    end

    describe ".for_provider" do
      it "returns connections for specific provider" do
        expect(CalendarConnection.for_provider("google")).to contain_exactly(enabled_google)
      end
    end

    describe ".google" do
      it "returns only Google connections" do
        expect(CalendarConnection.google).to contain_exactly(enabled_google)
      end
    end

    describe ".apple" do
      it "returns only Apple connections" do
        expect(CalendarConnection.apple).to contain_exactly(disabled_google)
      end
    end
  end

  describe "instance methods" do
    let(:google_connection) { create(:calendar_connection, user: user, provider: "google") }
    let(:apple_connection) { create(:calendar_connection, :apple, user: user) }

    describe "#google?" do
      it "returns true for Google connections" do
        expect(google_connection.google?).to be true
        expect(apple_connection.google?).to be false
      end
    end

    describe "#apple?" do
      it "returns true for Apple connections" do
        expect(apple_connection.apple?).to be true
        expect(google_connection.apple?).to be false
      end
    end

    describe "#token_expired?" do
      it "returns true when token is expired" do
        expired_connection = create(:calendar_connection, :expired, user: user)
        expect(expired_connection.token_expired?).to be true
      end

      it "returns false when token is not expired" do
        expect(google_connection.token_expired?).to be false
      end

      it "returns false when no expiration time is set" do
        no_expiry_connection = create(:calendar_connection, user: user, token_expires_at: nil)
        expect(no_expiry_connection.token_expired?).to be false
      end
    end

    describe "#needs_refresh?" do
      it "returns true when token is expired and refresh token is present" do
        expired_connection = create(:calendar_connection, :expired, user: user)
        expect(expired_connection.needs_refresh?).to be true
      end

      it "returns false when token is not expired" do
        expect(google_connection.needs_refresh?).to be false
      end

      it "returns false when token is expired but no refresh token" do
        expired_no_refresh = create(:calendar_connection, :expired, :without_refresh_token, user: user)
        expect(expired_no_refresh.needs_refresh?).to be false
      end
    end

    describe "#disable!" do
      it "disables the connection" do
        expect { google_connection.disable! }.to change { google_connection.enabled }.to(false)
      end
    end

    describe "#enable!" do
      let(:disabled_connection) { create(:calendar_connection, :disabled, user: user) }

      it "enables the connection" do
        expect { disabled_connection.enable! }.to change { disabled_connection.enabled }.to(true)
      end
    end
  end

  describe "encryption" do
    it "encrypts access_token and refresh_token" do
      connection = create(:calendar_connection, user: user, access_token: "secret_token", refresh_token: "secret_refresh")
      
      # Check that the raw values in database are encrypted (not the original values)
      raw_attributes = CalendarConnection.connection.execute("SELECT access_token, refresh_token FROM calendar_connections WHERE id = #{connection.id}").first
      
      expect(raw_attributes["access_token"]).not_to eq("secret_token")
      expect(raw_attributes["refresh_token"]).not_to eq("secret_refresh")
      
      # But the model should decrypt them correctly
      expect(connection.access_token).to eq("secret_token")
      expect(connection.refresh_token).to eq("secret_refresh")
    end
  end
end