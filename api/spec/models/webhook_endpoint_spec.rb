require 'rails_helper'

RSpec.describe WebhookEndpoint, type: :model do
  let(:organization) { create(:organization) }
  let(:webhook_endpoint) { create(:webhook_endpoint, organization: organization) }

  describe "associations" do
    it { should belong_to(:organization) }
    it { should have_many(:webhook_events).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:url) }
    it { should validate_presence_of(:secret) }
    it { should validate_presence_of(:events) }

    context "url validation" do
      it "accepts https URLs" do
        endpoint = build(:webhook_endpoint, url: "https://example.com/webhook")
        expect(endpoint).to be_valid
      end

      it "rejects http URLs" do
        endpoint = build(:webhook_endpoint, url: "http://example.com/webhook")
        expect(endpoint).not_to be_valid
        expect(endpoint.errors[:url]).to include("must be a valid HTTPS URL")
      end

      it "rejects invalid URLs" do
        endpoint = build(:webhook_endpoint, url: "not-a-url")
        expect(endpoint).not_to be_valid
      end
    end

    context "secret validation" do
      it "requires a secret of at least 32 characters" do
        endpoint = build(:webhook_endpoint, secret: "short")
        expect(endpoint).not_to be_valid
        expect(endpoint.errors[:secret]).to include("is too short (minimum is 32 characters)")
      end

      it "accepts a 32+ character secret" do
        endpoint = build(:webhook_endpoint, secret: SecureRandom.hex(32))
        expect(endpoint).to be_valid
      end
    end

    context "events validation" do
      it "accepts valid event types" do
        endpoint = build(:webhook_endpoint, events: ["booking.created", "payment.completed"])
        expect(endpoint).to be_valid
      end

      it "rejects invalid event types" do
        endpoint = build(:webhook_endpoint, events: ["invalid.event", "booking.created"])
        expect(endpoint).not_to be_valid
        expect(endpoint.errors[:events]).to include("contains invalid event types: invalid.event")
      end

      it "removes duplicates from events array" do
        endpoint = create(:webhook_endpoint, events: ["booking.created", "booking.created", "payment.completed"])
        expect(endpoint.events).to eq(["booking.created", "payment.completed"])
      end
    end
  end

  describe "scopes" do
    let!(:active_endpoint) { create(:webhook_endpoint, active: true) }
    let!(:inactive_endpoint) { create(:webhook_endpoint, :inactive) }

    describe ".active" do
      it "returns only active endpoints" do
        expect(WebhookEndpoint.active).to include(active_endpoint)
        expect(WebhookEndpoint.active).not_to include(inactive_endpoint)
      end
    end

    describe ".for_organization" do
      let!(:other_org_endpoint) { create(:webhook_endpoint) }

      it "returns only endpoints for the specified organization" do
        results = WebhookEndpoint.for_organization(organization)
        expect(results).to include(webhook_endpoint)
        expect(results).not_to include(other_org_endpoint)
      end
    end

    describe ".subscribed_to_event" do
      let!(:booking_endpoint) { create(:webhook_endpoint, events: ["booking.created", "booking.cancelled"]) }
      let!(:payment_endpoint) { create(:webhook_endpoint, events: ["payment.completed"]) }

      it "returns endpoints subscribed to the specified event" do
        results = WebhookEndpoint.subscribed_to_event("booking.created")
        expect(results).to include(booking_endpoint)
        expect(results).not_to include(payment_endpoint)
      end
    end
  end

  describe "callbacks" do
    context "before_validation" do
      it "generates a secret if blank" do
        endpoint = build(:webhook_endpoint, secret: nil)
        endpoint.valid?
        expect(endpoint.secret).to be_present
        expect(endpoint.secret.length).to be >= 32
      end

      it "doesn't overwrite existing secret" do
        original_secret = SecureRandom.hex(32)
        endpoint = build(:webhook_endpoint, secret: original_secret)
        endpoint.valid?
        expect(endpoint.secret).to eq(original_secret)
      end

      it "ensures events is an array" do
        endpoint = build(:webhook_endpoint, events: nil)
        endpoint.valid?
        expect(endpoint.events).to eq([])
      end
    end
  end

  describe "instance methods" do
    describe "#subscribed_to?" do
      it "returns true if subscribed to event" do
        endpoint = create(:webhook_endpoint, events: ["booking.created", "payment.completed"])
        expect(endpoint.subscribed_to?("booking.created")).to be true
        expect(endpoint.subscribed_to?(:booking_created)).to be false  # Different format
      end

      it "returns false if not subscribed to event" do
        endpoint = create(:webhook_endpoint, events: ["booking.created"])
        expect(endpoint.subscribed_to?("payment.completed")).to be false
      end
    end

    describe "#recent_events" do
      it "returns recent webhook events in descending order" do
        event1 = create(:webhook_event, webhook_endpoint: webhook_endpoint, created_at: 2.hours.ago)
        event2 = create(:webhook_event, webhook_endpoint: webhook_endpoint, created_at: 1.hour.ago)
        
        recent = webhook_endpoint.recent_events
        expect(recent.first).to eq(event2)
        expect(recent.last).to eq(event1)
      end

      it "limits to specified number of events" do
        3.times { create(:webhook_event, webhook_endpoint: webhook_endpoint) }
        
        recent = webhook_endpoint.recent_events(2)
        expect(recent.count).to eq(2)
      end
    end

    describe "#success_rate" do
      before do
        # Create some events with different statuses
        create(:webhook_event, :delivered, webhook_endpoint: webhook_endpoint, created_at: 1.day.ago)
        create(:webhook_event, :delivered, webhook_endpoint: webhook_endpoint, created_at: 2.days.ago)
        create(:webhook_event, :failed, webhook_endpoint: webhook_endpoint, created_at: 3.days.ago)
      end

      it "calculates success rate over the specified period" do
        # 2 successful out of 3 total = 66.67%
        expect(webhook_endpoint.success_rate(7)).to eq(66.67)
      end

      it "returns 0 if no events" do
        empty_endpoint = create(:webhook_endpoint)
        expect(empty_endpoint.success_rate).to eq(0)
      end
    end
  end

  describe "constants" do
    it "defines available events" do
      expected_events = [
        'booking.created',
        'booking.cancelled', 
        'booking.checked_in',
        'tee_time.updated',
        'payment.completed',
        'payment.refunded'
      ]
      
      expect(WebhookEndpoint::AVAILABLE_EVENTS).to eq(expected_events)
    end
  end
end