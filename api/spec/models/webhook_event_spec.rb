require 'rails_helper'

RSpec.describe WebhookEvent, type: :model do
  let(:organization) { create(:organization) }
  let(:webhook_endpoint) { create(:webhook_endpoint, organization: organization) }
  let(:webhook_event) { create(:webhook_event, webhook_endpoint: webhook_endpoint) }

  describe "associations" do
    it { should belong_to(:webhook_endpoint) }
  end

  describe "validations" do
    it { should validate_presence_of(:event_type) }
    it { should validate_presence_of(:payload) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:attempts) }
    it { should validate_numericality_of(:attempts).is_greater_than_or_equal_to(0) }
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values(pending: 0, delivered: 1, failed: 2) }
  end

  describe "scopes" do
    let!(:event1) { create(:webhook_event, webhook_endpoint: webhook_endpoint, created_at: 1.hour.ago) }
    let!(:event2) { create(:webhook_event, webhook_endpoint: webhook_endpoint, created_at: 2.hours.ago) }
    let!(:other_org_event) { create(:webhook_event, created_at: 30.minutes.ago) }

    describe ".for_organization" do
      it "returns events for the specified organization" do
        results = WebhookEvent.for_organization(organization)
        expect(results).to include(event1, event2)
        expect(results).not_to include(other_org_event)
      end
    end

    describe ".recent" do
      it "returns events in descending order by created_at" do
        results = WebhookEvent.recent
        expect(results.first.created_at).to be > results.last.created_at
      end
    end

    describe ".pending_retry" do
      let!(:pending_event) { create(:webhook_event, status: :pending, attempts: 2) }
      let!(:max_attempts_event) { create(:webhook_event, status: :pending, attempts: 5) }
      let!(:delivered_event) { create(:webhook_event, :delivered) }

      it "returns pending events with less than 5 attempts" do
        results = WebhookEvent.pending_retry
        expect(results).to include(pending_event)
        expect(results).not_to include(max_attempts_event, delivered_event)
      end
    end

    describe ".recent_failures" do
      let!(:recent_failure) { create(:webhook_event, :failed, created_at: 30.minutes.ago) }
      let!(:old_failure) { create(:webhook_event, :failed, created_at: 2.hours.ago) }

      it "returns failed events from the last hour" do
        results = WebhookEvent.recent_failures
        expect(results).to include(recent_failure)
        expect(results).not_to include(old_failure)
      end
    end
  end

  describe "instance methods" do
    describe "#should_retry?" do
      it "returns true for pending events with less than 5 attempts" do
        event = create(:webhook_event, status: :pending, attempts: 3)
        expect(event.should_retry?).to be true
      end

      it "returns false for events with 5 or more attempts" do
        event = create(:webhook_event, status: :pending, attempts: 5)
        expect(event.should_retry?).to be false
      end

      it "returns false for delivered events" do
        event = create(:webhook_event, :delivered, attempts: 1)
        expect(event.should_retry?).to be false
      end

      it "returns false for failed events" do
        event = create(:webhook_event, :failed, attempts: 3)
        expect(event.should_retry?).to be false
      end
    end

    describe "#next_retry_delay" do
      it "returns 0 for events that should not retry" do
        event = create(:webhook_event, :delivered)
        expect(event.next_retry_delay).to eq(0)
      end

      it "calculates exponential backoff delay" do
        event = create(:webhook_event, status: :pending, attempts: 2)
        # Base delay 30, attempts 2: 30 * (2^2) = 120 seconds + jitter
        delay = event.next_retry_delay
        expect(delay).to be_between(120, 160)  # Allowing for jitter
      end

      it "increases delay with more attempts" do
        event1 = create(:webhook_event, status: :pending, attempts: 1)
        event2 = create(:webhook_event, status: :pending, attempts: 2)
        
        expect(event2.next_retry_delay).to be > event1.next_retry_delay
      end
    end

    describe "#mark_delivered!" do
      it "updates status and sets delivered_at" do
        event = create(:webhook_event, status: :pending)
        event.mark_delivered!(200, "OK")
        
        expect(event.reload).to be_delivered
        expect(event.delivered_at).to be_present
        expect(event.response_code).to eq(200)
        expect(event.response_body).to eq("OK")
      end

      it "truncates long response bodies" do
        long_body = "x" * 2000
        event = create(:webhook_event, status: :pending)
        event.mark_delivered!(200, long_body)
        
        expect(event.reload.response_body.length).to eq(1000)
        expect(event.response_body).to end_with("...")
      end
    end

    describe "#mark_failed!" do
      it "updates status and sets last_attempted_at" do
        event = create(:webhook_event, status: :pending)
        event.mark_failed!(500, "Internal Server Error")
        
        expect(event.reload).to be_failed
        expect(event.last_attempted_at).to be_present
        expect(event.response_code).to eq(500)
        expect(event.response_body).to eq("Internal Server Error")
      end
    end

    describe "#increment_attempts!" do
      it "increments attempts counter and sets last_attempted_at" do
        event = create(:webhook_event, attempts: 2)
        original_time = event.last_attempted_at
        
        event.increment_attempts!
        
        expect(event.reload.attempts).to eq(3)
        expect(event.last_attempted_at).to be > original_time if original_time
      end
    end

    describe "#organization" do
      it "returns the organization through webhook_endpoint" do
        expect(webhook_event.organization).to eq(organization)
      end
    end

    describe "#valid_event_type?" do
      it "returns true for valid event types" do
        event = create(:webhook_event, event_type: "booking.created")
        expect(event.valid_event_type?).to be true
      end

      it "returns false for invalid event types" do
        event = build(:webhook_event, event_type: "invalid.event")
        # Need to skip validation to create with invalid event type
        event.save(validate: false)
        expect(event.valid_event_type?).to be false
      end
    end
  end
end
