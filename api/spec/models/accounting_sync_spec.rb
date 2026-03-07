require "rails_helper"

RSpec.describe AccountingSync, type: :model do
  let(:organization) { create(:organization) }
  let(:integration) do
    AccountingIntegration.create!(
      organization: organization,
      provider: :quickbooks,
      status: :connected,
      access_token: "token",
      account_mapping: {}
    )
  end
  let(:booking) { create(:booking, organization: organization) }

  subject(:sync) do
    described_class.new(
      accounting_integration: integration,
      sync_type: "invoice",
      status: :pending,
      syncable: booking
    )
  end

  describe "associations" do
    it { is_expected.to belong_to(:accounting_integration) }
    it { is_expected.to belong_to(:syncable) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:sync_type) }
    it { is_expected.to validate_presence_of(:accounting_integration) }

    it { is_expected.to validate_inclusion_of(:sync_type).in_array(%w[invoice payment refund]) }
  end

  describe "scopes" do
    before { sync.save! }

    describe ".recent" do
      it "orders by created_at desc" do
        older = described_class.create!(
          accounting_integration: integration,
          sync_type: "payment",
          status: :completed,
          syncable: booking,
          created_at: 1.day.ago
        )

        expect(described_class.recent.first).to eq(sync)
        expect(described_class.recent.last).to eq(older)
      end
    end

    describe ".failed" do
      it "returns only failed syncs" do
        sync.update!(status: :failed, error_message: "test")
        completed = described_class.create!(
          accounting_integration: integration,
          sync_type: "payment",
          status: :completed,
          syncable: booking
        )

        expect(described_class.failed).to contain_exactly(sync)
        expect(described_class.failed).not_to include(completed)
      end
    end

    describe ".for_organization" do
      it "returns syncs for the given organization" do
        other_org = create(:organization)
        other_integration = AccountingIntegration.create!(
          organization: other_org,
          provider: :xero,
          status: :connected,
          account_mapping: {}
        )
        other_sync = described_class.create!(
          accounting_integration: other_integration,
          sync_type: "invoice",
          status: :pending,
          syncable: create(:booking, organization: other_org)
        )

        expect(described_class.for_organization(organization)).to contain_exactly(sync)
        expect(described_class.for_organization(organization)).not_to include(other_sync)
      end
    end
  end

  describe "#start!" do
    before { sync.save! }

    it "marks sync as in_progress" do
      sync.start!

      expect(sync.status).to eq("in_progress")
      expect(sync.started_at).to be_present
      expect(sync.error_message).to be_nil
    end
  end

  describe "#complete!" do
    before do
      sync.save!
      sync.start!
    end

    it "marks sync as completed with external id" do
      sync.complete!("EXT-001", { response: "data" })

      expect(sync.status).to eq("completed")
      expect(sync.external_id).to eq("EXT-001")
      expect(sync.completed_at).to be_present
      expect(sync.error_message).to be_nil
    end
  end

  describe "#fail!" do
    before { sync.save! }

    it "marks sync as failed with error message" do
      sync.fail!("Something went wrong")

      expect(sync.status).to eq("failed")
      expect(sync.error_message).to eq("Something went wrong")
      expect(sync.error_at).to be_present
      expect(sync.retry_count).to eq(1)
    end

    it "sets next_retry_at for retryable failures" do
      sync.fail!("Temporary error")

      expect(sync.next_retry_at).to be_present
      expect(sync.next_retry_at).to be > Time.current
    end

    it "increments retry count on each failure" do
      3.times { sync.fail!("Error") }

      expect(sync.retry_count).to eq(3)
    end
  end

  describe "#retryable?" do
    before { sync.save! }

    it "returns true when failed with retries remaining and past retry time" do
      sync.update!(
        status: :failed,
        retry_count: 1,
        next_retry_at: 1.minute.ago
      )

      expect(sync.retryable?).to be true
    end

    it "returns false when retry count exceeds max" do
      sync.update!(
        status: :failed,
        retry_count: 4,
        next_retry_at: 1.minute.ago
      )

      expect(sync.retryable?).to be false
    end

    it "returns false when not in failed status" do
      sync.update!(status: :completed)

      expect(sync.retryable?).to be false
    end

    it "returns false when next_retry_at is in the future" do
      sync.update!(
        status: :failed,
        retry_count: 1,
        next_retry_at: 1.hour.from_now
      )

      expect(sync.retryable?).to be false
    end
  end

  describe "#reset_for_retry!" do
    before do
      sync.save!
      sync.fail!("Error")
    end

    it "resets status to pending and clears error info" do
      sync.reset_for_retry!

      expect(sync.status).to eq("pending")
      expect(sync.error_message).to be_nil
      expect(sync.error_at).to be_nil
      expect(sync.started_at).to be_nil
    end
  end

  describe "#sync_type_humanized" do
    it "returns humanized sync type" do
      expect(sync.sync_type_humanized).to eq("Invoice")
    end

    it "returns Payment for payment type" do
      sync.sync_type = "payment"
      expect(sync.sync_type_humanized).to eq("Payment")
    end

    it "returns Refund for refund type" do
      sync.sync_type = "refund"
      expect(sync.sync_type_humanized).to eq("Refund")
    end
  end

  describe "#organization" do
    it "delegates to accounting_integration" do
      expect(sync.organization).to eq(organization)
    end
  end

  describe "#provider" do
    it "delegates to accounting_integration" do
      expect(sync.provider).to eq("quickbooks")
    end
  end

  describe "#duration" do
    it "returns nil when not started" do
      expect(sync.duration).to be_nil
    end

    it "returns nil when not completed" do
      sync.started_at = 5.minutes.ago
      expect(sync.duration).to be_nil
    end

    it "returns duration in seconds when completed" do
      sync.started_at = 10.seconds.ago
      sync.completed_at = Time.current

      expect(sync.duration).to be_within(1).of(10)
    end
  end
end
