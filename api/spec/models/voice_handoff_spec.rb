require "rails_helper"

RSpec.describe VoiceHandoff, type: :model do
  let(:organization) { create(:organization) }
  let(:voice_call_log) { create(:voice_call_log, organization: organization) }

  describe "associations" do
    it { should belong_to(:organization) }
    it { should belong_to(:voice_call_log).optional }
  end

  describe "validations" do
    subject { build(:voice_handoff, organization: organization) }

    it { should validate_presence_of(:call_sid) }
    it { should validate_presence_of(:caller_phone) }
    it { should validate_presence_of(:reason) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:transfer_to) }
    it { should validate_presence_of(:started_at) }
    it { should validate_uniqueness_of(:call_sid) }

    context "when status is connected or completed" do
      subject { build(:voice_handoff, :connected, organization: organization) }

      it { should validate_presence_of(:connected_at) }
    end

    context "when status is completed" do
      subject { build(:voice_handoff, :completed, organization: organization) }

      it { should validate_presence_of(:completed_at) }
      it { should validate_presence_of(:resolution_notes) }
    end
  end

  describe "enums" do
    it {
      should define_enum_for(:status)
        .with_values(
          pending: "pending",
          connected: "connected",
          completed: "completed",
          missed: "missed",
          cancelled: "cancelled"
        )
        .with_prefix(false)
        .with_suffix(false)
    }

    it {
      should define_enum_for(:reason)
        .with_values(
          billing_inquiry: "billing_inquiry",
          complaint: "complaint",
          group_event: "group_event",
          tournament: "tournament",
          manager_request: "manager_request",
          other: "other"
        )
        .with_prefix(false)
        .with_suffix(false)
    }
  end

  describe "scopes" do
    let!(:pending_handoff) { create(:voice_handoff, :pending, organization: organization) }
    let!(:completed_handoff) { create(:voice_handoff, :completed, organization: organization) }
    let!(:other_org_handoff) { create(:voice_handoff, :pending) }

    describe ".for_organization" do
      it "returns handoffs for the given organization" do
        expect(VoiceHandoff.for_organization(organization)).to contain_exactly(
          pending_handoff, completed_handoff
        )
      end
    end

    describe ".recent" do
      let!(:old_handoff) { create(:voice_handoff, started_at: 2.days.ago, organization: organization) }

      it "returns handoffs from the last 24 hours by default" do
        expect(VoiceHandoff.recent).to contain_exactly(
          pending_handoff, completed_handoff, other_org_handoff
        )
      end

      it "accepts custom hours" do
        expect(VoiceHandoff.recent(48)).to include(old_handoff)
      end
    end

    describe ".by_reason" do
      let!(:billing_handoff) { create(:voice_handoff, reason: :billing_inquiry, organization: organization) }

      it "filters by reason" do
        expect(VoiceHandoff.by_reason(:billing_inquiry)).to contain_exactly(billing_handoff)
      end
    end

    describe ".active" do
      let!(:connected_handoff) { create(:voice_handoff, :connected, organization: organization) }

      it "returns pending and connected handoffs" do
        expect(VoiceHandoff.active).to contain_exactly(
          pending_handoff, connected_handoff
        )
      end
    end

    describe ".pending_handoffs" do
      it "returns only pending handoffs" do
        expect(VoiceHandoff.pending_handoffs).to contain_exactly(pending_handoff, other_org_handoff)
      end
    end

    describe ".completed_handoffs" do
      it "returns completed, missed, and cancelled handoffs" do
        missed = create(:voice_handoff, :missed, organization: organization)
        cancelled = create(:voice_handoff, :cancelled, organization: organization)

        expect(VoiceHandoff.completed_handoffs).to contain_exactly(
          completed_handoff, missed, cancelled
        )
      end
    end
  end

  describe "callbacks" do
    describe "#set_started_at" do
      it "sets started_at if not provided" do
        handoff = build(:voice_handoff, organization: organization, started_at: nil)
        
        freeze_time do
          handoff.save!
          expect(handoff.started_at).to eq(Time.current)
        end
      end

      it "does not override provided started_at" do
        custom_time = 1.hour.ago
        handoff = build(:voice_handoff, organization: organization, started_at: custom_time)
        
        handoff.save!
        expect(handoff.started_at).to eq(custom_time)
      end
    end
  end

  describe "instance methods" do
    let(:handoff) { create(:voice_handoff, organization: organization, caller_phone: "+15551234567") }

    describe "#duration_seconds" do
      context "when connected_at and completed_at are present" do
        it "returns the duration between connected_at and completed_at" do
          handoff.update!(
            connected_at: 10.minutes.ago,
            completed_at: 5.minutes.ago
          )

          expect(handoff.duration_seconds).to eq(300) # 5 minutes
        end
      end

      context "when connected_at is present but completed_at is not" do
        it "returns duration from connected_at to now" do
          freeze_time do
            handoff.update!(connected_at: 5.minutes.ago)
            expect(handoff.duration_seconds).to eq(300)
          end
        end
      end

      context "when connected_at is not present" do
        it "returns nil" do
          expect(handoff.duration_seconds).to be_nil
        end
      end
    end

    describe "#wait_duration_seconds" do
      context "when wait_seconds is present" do
        it "returns wait_seconds" do
          handoff.update!(wait_seconds: 45)
          expect(handoff.wait_duration_seconds).to eq(45)
        end
      end

      context "when wait_seconds is not present but timestamps are" do
        it "calculates from started_at to connected_at" do
          handoff.update!(
            started_at: 10.minutes.ago,
            connected_at: 8.minutes.ago
          )

          expect(handoff.wait_duration_seconds).to eq(120) # 2 minutes
        end
      end

      context "when timestamps are missing" do
        it "returns nil" do
          expect(handoff.wait_duration_seconds).to be_nil
        end
      end
    end

    describe "#active?" do
      it "returns true for pending status" do
        handoff.update!(status: :pending)
        expect(handoff).to be_active
      end

      it "returns true for connected status" do
        handoff.update!(status: :connected)
        expect(handoff).to be_active
      end

      it "returns false for completed status" do
        handoff.update!(status: :completed)
        expect(handoff).not_to be_active
      end
    end

    describe "#formatted_caller_phone" do
      context "with US phone number" do
        it "formats as (XXX) XXX-XXXX" do
          handoff.update!(caller_phone: "+15551234567")
          expect(handoff.formatted_caller_phone).to eq("(555) 123-4567")
        end

        it "handles number without +1 prefix" do
          handoff.update!(caller_phone: "5551234567")
          expect(handoff.formatted_caller_phone).to eq("(555) 123-4567")
        end
      end

      context "with international number" do
        it "returns the original number" do
          handoff.update!(caller_phone: "+441234567890")
          expect(handoff.formatted_caller_phone).to eq("+441234567890")
        end
      end
    end

    describe "#caller_display_name" do
      context "when caller_name is present" do
        it "returns caller_name" do
          handoff.update!(caller_name: "John Doe")
          expect(handoff.caller_display_name).to eq("John Doe")
        end
      end

      context "when caller_name is blank" do
        it "returns formatted_caller_phone" do
          handoff.update!(caller_name: nil, caller_phone: "+15551234567")
          expect(handoff.caller_display_name).to eq("(555) 123-4567")
        end
      end
    end
  end
end