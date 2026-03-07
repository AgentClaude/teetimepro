# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailMessage, type: :model do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:campaign) { create(:email_campaign, organization: organization, created_by: user) }

  describe 'validations' do
    subject { build(:email_message, email_campaign: campaign, user: user) }

    it { should belong_to(:email_campaign) }
    it { should belong_to(:user) }

    it { should validate_presence_of(:to_email) }
    
    it 'validates email format' do
      message = build(:email_message, email_campaign: campaign, user: user, to_email: 'invalid-email')
      expect(message).not_to be_valid
      expect(message.errors[:to_email]).to include('is invalid')
    end

    it 'accepts valid email format' do
      message = build(:email_message, email_campaign: campaign, user: user, to_email: 'test@example.com')
      expect(message).to be_valid
    end
  end

  describe 'enums' do
    it 'defines status enum' do
      expect(EmailMessage.statuses).to eq({
        'pending' => 0,
        'sent' => 1,
        'delivered' => 2,
        'opened' => 3,
        'clicked' => 4,
        'bounced' => 5,
        'failed' => 6
      })
    end
  end

  describe 'scopes' do
    let!(:message1) { create(:email_message, email_campaign: campaign, user: user, status: :sent) }
    let!(:message2) { create(:email_message, email_campaign: campaign, user: create(:user, organization: organization), status: :delivered) }
    let!(:message3) { create(:email_message, email_campaign: campaign, user: create(:user, organization: organization), status: :bounced) }
    let!(:message4) { create(:email_message, email_campaign: campaign, user: create(:user, organization: organization), status: :failed) }

    describe '.by_campaign' do
      it 'returns messages for the specified campaign' do
        other_campaign = create(:email_campaign, organization: organization, created_by: user)
        other_message = create(:email_message, email_campaign: other_campaign, user: user)
        
        expect(EmailMessage.by_campaign(campaign)).to contain_exactly(message1, message2, message3, message4)
      end
    end

    describe '.successful' do
      it 'returns messages with successful statuses' do
        expect(EmailMessage.successful).to contain_exactly(message1, message2)
      end
    end

    describe '.unsuccessful' do
      it 'returns messages with failed/bounced statuses' do
        expect(EmailMessage.unsuccessful).to contain_exactly(message3, message4)
      end
    end
  end

  describe 'instance methods' do
    let(:message) { create(:email_message, email_campaign: campaign, user: user, status: :sent) }

    describe '#delivery_confirmed?' do
      it 'returns true for delivered status' do
        message.update!(status: :delivered)
        expect(message.delivery_confirmed?).to be true
      end

      it 'returns true for opened status' do
        message.update!(status: :opened)
        expect(message.delivery_confirmed?).to be true
      end

      it 'returns true for clicked status' do
        message.update!(status: :clicked)
        expect(message.delivery_confirmed?).to be true
      end

      it 'returns false for other statuses' do
        message.update!(status: :pending)
        expect(message.delivery_confirmed?).to be false
      end
    end

    describe '#errored?' do
      it 'returns true for bounced status' do
        message.update!(status: :bounced)
        expect(message.errored?).to be true
      end

      it 'returns true for failed status' do
        message.update!(status: :failed)
        expect(message.errored?).to be true
      end

      it 'returns false for other statuses' do
        message.update!(status: :sent)
        expect(message.errored?).to be false
      end
    end

    describe '#mark_opened!' do
      it 'updates status to opened and sets opened_at' do
        freeze_time do
          message.mark_opened!
          expect(message.status).to eq('opened')
          expect(message.opened_at).to eq(Time.current)
        end
      end

      it 'updates from delivered status' do
        message.update!(status: :delivered)
        message.mark_opened!
        expect(message.status).to eq('opened')
      end

      it 'does not update from failed status' do
        message.update!(status: :failed)
        message.mark_opened!
        expect(message.status).to eq('failed')
      end
    end

    describe '#mark_clicked!' do
      it 'updates status to clicked and sets clicked_at' do
        freeze_time do
          message.mark_clicked!
          expect(message.status).to eq('clicked')
          expect(message.clicked_at).to eq(Time.current)
        end
      end

      it 'updates from any non-failed status' do
        message.update!(status: :pending)
        message.mark_clicked!
        expect(message.status).to eq('clicked')
      end

      it 'does not update from bounced status' do
        message.update!(status: :bounced)
        message.mark_clicked!
        expect(message.status).to eq('bounced')
      end
    end

    describe '#mark_delivered!' do
      it 'updates status to delivered and sets delivered_at' do
        freeze_time do
          message.mark_delivered!
          expect(message.status).to eq('delivered')
          expect(message.delivered_at).to eq(Time.current)
        end
      end

      it 'only updates from sent status' do
        message.update!(status: :pending)
        message.mark_delivered!
        expect(message.status).to eq('pending')
      end
    end

    describe '#mark_bounced!' do
      it 'updates status to bounced with error message' do
        message.mark_bounced!('Invalid email address')
        expect(message.status).to eq('bounced')
        expect(message.error_message).to eq('Invalid email address')
      end
    end

    describe '#mark_failed!' do
      it 'updates status to failed with error message' do
        message.mark_failed!('SMTP error')
        expect(message.status).to eq('failed')
        expect(message.error_message).to eq('SMTP error')
      end
    end

    describe '#mark_sent!' do
      it 'updates status to sent and sets sent_at and message_id' do
        freeze_time do
          message.mark_sent!('msg123')
          expect(message.status).to eq('sent')
          expect(message.sent_at).to eq(Time.current)
          expect(message.message_id).to eq('msg123')
        end
      end

      it 'works without message_id' do
        message.mark_sent!
        expect(message.status).to eq('sent')
        expect(message.message_id).to be_nil
      end
    end
  end
end
