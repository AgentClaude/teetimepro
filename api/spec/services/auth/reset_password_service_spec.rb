require "rails_helper"

RSpec.describe Auth::ResetPasswordService do
  describe ".call" do
    let(:user) { create(:user, email: "user@example.com") }
    let(:raw_token) { SecureRandom.urlsafe_base64(32) }
    let(:hashed_token) { Digest::SHA256.hexdigest(raw_token) }

    before do
      user.update!(
        reset_password_token: hashed_token,
        reset_password_sent_at: 30.minutes.ago
      )
    end

    context "with valid token and matching passwords" do
      it "resets the password" do
        result = described_class.call(
          token: raw_token,
          password: "newpassword123",
          password_confirmation: "newpassword123"
        )

        expect(result).to be_success

        user.reload
        expect(user.valid_password?("newpassword123")).to be true
        expect(user.reset_password_token).to be_nil
        expect(user.reset_password_sent_at).to be_nil
      end
    end

    context "with expired token" do
      before do
        user.update!(reset_password_sent_at: 3.hours.ago)
      end

      it "returns failure" do
        result = described_class.call(
          token: raw_token,
          password: "newpassword123",
          password_confirmation: "newpassword123"
        )

        expect(result).not_to be_success
        expect(result.errors).to include(/expired/i)
      end
    end

    context "with invalid token" do
      it "returns failure" do
        result = described_class.call(
          token: "invalid-token",
          password: "newpassword123",
          password_confirmation: "newpassword123"
        )

        expect(result).not_to be_success
        expect(result.errors).to include(/invalid/i)
      end
    end

    context "with password mismatch" do
      it "returns failure" do
        result = described_class.call(
          token: raw_token,
          password: "newpassword123",
          password_confirmation: "different"
        )

        expect(result).not_to be_success
      end
    end

    context "with too short password" do
      it "returns failure" do
        result = described_class.call(
          token: raw_token,
          password: "short",
          password_confirmation: "short"
        )

        expect(result).not_to be_success
      end
    end
  end
end
