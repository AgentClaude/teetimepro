# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailCampaign, type: :model do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }

  describe 'validations' do
    subject { build(:email_campaign, organization: organization, created_by: user) }

    it { should belong_to(:organization) }
    it { should belong_to(:created_by).class_name('User') }
    it { should have_many(:email_messages).dependent(:destroy) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:body_html) }
    it { should validate_presence_of(:lapsed_days) }
    it { should validate_numericality_of(:lapsed_days).is_greater_than(0) }
    it { should validate_numericality_of(:recurrence_interval_days).is_greater_than(0).allow_nil }
  end

  describe 'enums' do
    it 'defines status enum' do
      expect(EmailCampaign.statuses).to eq({
        'draft' => 0,
        'scheduled' => 1,
        'sending' => 2,
        'completed' => 3,
        'cancelled' => 4,
        'failed' => 5
      })
    end

    it 'defines recipient_filter enum' do
      expect(EmailCampaign.recipient_filters).to eq({
        'all' => 'all',
        'members_only' => 'members_only',
        'recent_bookers' => 'recent_bookers',
        'inactive' => 'inactive',
        'lapsed' => 'lapsed',
        'segment' => 'segment'
      })
    end
  end

  describe 'scopes' do
    let!(:campaign1) { create(:email_campaign, organization: organization, created_by: user) }
    let!(:campaign2) { create(:email_campaign, organization: create(:organization), created_by: create(:user)) }
    let!(:scheduled_campaign) { create(:email_campaign, :scheduled, organization: organization, created_by: user, scheduled_at: 1.hour.ago) }
    let!(:automated_campaign) { create(:email_campaign, :automated, organization: organization, created_by: user, status: :completed, completed_at: 2.days.ago, recurrence_interval_days: 1) }

    describe '.by_organization' do
      it 'returns campaigns for the specified organization' do
        expect(EmailCampaign.by_organization(organization)).to contain_exactly(campaign1, scheduled_campaign, automated_campaign)
      end
    end

    describe '.pending_send' do
      it 'returns scheduled campaigns past their scheduled time' do
        expect(EmailCampaign.pending_send).to contain_exactly(scheduled_campaign)
      end
    end

    describe '.automated' do
      it 'returns only automated campaigns' do
        expect(EmailCampaign.automated).to contain_exactly(automated_campaign)
      end
    end

    describe '.due_for_automation' do
      it 'returns automated campaigns ready for next run' do
        expect(EmailCampaign.due_for_automation).to contain_exactly(automated_campaign)
      end
    end
  end

  describe 'instance methods' do
    let(:campaign) { create(:email_campaign, organization: organization, created_by: user, total_recipients: 100, sent_count: 60, failed_count: 10, opened_count: 25, clicked_count: 8) }

    describe '#progress_percentage' do
      it 'calculates progress correctly' do
        expect(campaign.progress_percentage).to eq(70.0)
      end

      it 'returns 0 for zero total recipients' do
        campaign.update!(total_recipients: 0)
        expect(campaign.progress_percentage).to eq(0)
      end
    end

    describe '#open_rate_percentage' do
      it 'calculates open rate correctly' do
        expect(campaign.open_rate_percentage).to eq(41.7) # 25/60 * 100 rounded to 1 decimal
      end

      it 'returns 0 for zero sent count' do
        campaign.update!(sent_count: 0)
        expect(campaign.open_rate_percentage).to eq(0)
      end
    end

    describe '#click_rate_percentage' do
      it 'calculates click rate correctly' do
        expect(campaign.click_rate_percentage).to eq(13.3) # 8/60 * 100 rounded to 1 decimal
      end

      it 'returns 0 for zero sent count' do
        campaign.update!(sent_count: 0)
        expect(campaign.click_rate_percentage).to eq(0)
      end
    end

    describe '#can_send?' do
      it 'returns true for draft campaigns' do
        campaign.update!(status: :draft)
        expect(campaign.can_send?).to be true
      end

      it 'returns true for scheduled campaigns' do
        campaign.update!(status: :scheduled)
        expect(campaign.can_send?).to be true
      end

      it 'returns false for sending campaigns' do
        campaign.update!(status: :sending)
        expect(campaign.can_send?).to be false
      end

      it 'returns false for completed campaigns' do
        campaign.update!(status: :completed)
        expect(campaign.can_send?).to be false
      end
    end

    describe '#can_cancel?' do
      it 'returns true for draft campaigns' do
        campaign.update!(status: :draft)
        expect(campaign.can_cancel?).to be true
      end

      it 'returns true for scheduled campaigns' do
        campaign.update!(status: :scheduled)
        expect(campaign.can_cancel?).to be true
      end

      it 'returns true for sending campaigns' do
        campaign.update!(status: :sending)
        expect(campaign.can_cancel?).to be true
      end

      it 'returns false for completed campaigns' do
        campaign.update!(status: :completed)
        expect(campaign.can_cancel?).to be false
      end
    end

    describe '#ready_for_next_automation?' do
      let(:automated_campaign) do
        create(:email_campaign, :automated,
               organization: organization,
               created_by: user,
               status: :completed,
               completed_at: 2.days.ago,
               recurrence_interval_days: 1)
      end

      it 'returns true when automated campaign is due for next run' do
        expect(automated_campaign.ready_for_next_automation?).to be true
      end

      it 'returns false for non-automated campaigns' do
        campaign.update!(is_automated: false)
        expect(campaign.ready_for_next_automation?).to be false
      end

      it 'returns false for non-completed campaigns' do
        automated_campaign.update!(status: :sending)
        expect(automated_campaign.ready_for_next_automation?).to be false
      end

      it 'returns false when recurrence interval is not set' do
        automated_campaign.update!(recurrence_interval_days: nil)
        expect(automated_campaign.ready_for_next_automation?).to be false
      end

      it 'returns false when not enough time has passed' do
        automated_campaign.update!(completed_at: 1.hour.ago)
        expect(automated_campaign.ready_for_next_automation?).to be false
      end
    end
  end
end
