require "rails_helper"

RSpec.describe Auth::RequestPasswordResetService do
  before { ActiveJob::Base.queue_adapter = :test }

  describe ".call" do
    context "with existing user email" do
      let(:user) { create(:user, email: "user@example.com") }

      it "returns success" do
        result = described_class.call(email: user.email)

        expect(result).to be_success
        expect(result.data[:message]).to include("instructions have been sent")
      end

      it "sets reset token on user" do
        described_class.call(email: user.email)

        user.reload
        expect(user.reset_password_token).to be_present
        expect(user.reset_password_sent_at).to be_present
      end

      it "enqueues a mailer job" do
        expect {
          described_class.call(email: user.email)
        }.to have_enqueued_mail(PasswordResetMailer, :reset_instructions)
      end
    end

    context "with non-existent email" do
      it "still returns success (prevents enumeration)" do
        result = described_class.call(email: "nonexistent@example.com")

        expect(result).to be_success
      end

      it "does not enqueue a mailer" do
        expect {
          described_class.call(email: "nonexistent@example.com")
        }.not_to have_enqueued_mail(PasswordResetMailer)
      end
    end

    context "with blank email" do
      it "returns failure" do
        result = described_class.call(email: "")

        expect(result).not_to be_success
      end
    end
  end
end
