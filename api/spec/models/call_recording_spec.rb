require 'rails_helper'

RSpec.describe CallRecording, type: :model do
  let(:organization) { create(:organization) }

  describe 'associations' do
    it { should belong_to(:organization) }
    it { should belong_to(:voice_call_log).optional }
    it { should have_many(:call_transcriptions).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:call_recording, organization: organization) }

    it { should validate_presence_of(:call_sid) }
    it { should validate_presence_of(:recording_sid) }
    it { should validate_presence_of(:recording_url) }
    it { should validate_presence_of(:duration_seconds) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:format) }

    it { should validate_uniqueness_of(:recording_sid) }
    it { should validate_numericality_of(:duration_seconds).is_greater_than(0) }
    it { should validate_inclusion_of(:status).in_array(%w[pending processing completed failed]) }

    it 'validates recording_url format' do
      recording = build(:call_recording, recording_url: 'not-a-url')
      expect(recording).not_to be_valid
      expect(recording.errors[:recording_url]).to include('is invalid')
    end
  end

  describe 'scopes' do
    let!(:org1) { create(:organization) }
    let!(:org2) { create(:organization) }
    let!(:recording1) { create(:call_recording, organization: org1) }
    let!(:recording2) { create(:call_recording, organization: org2) }
    let!(:old_recording) { create(:call_recording, organization: org1, created_at: 2.days.ago) }

    describe '.for_organization' do
      it 'returns recordings for the specified organization' do
        expect(CallRecording.for_organization(org1)).to contain_exactly(recording1, old_recording)
      end
    end

    describe '.recent' do
      it 'orders recordings by created_at desc' do
        expect(CallRecording.recent.first).to eq(recording2)
      end
    end

    describe '.completed' do
      let!(:completed_recording) { create(:call_recording, :completed, organization: org1) }
      let!(:pending_recording) { create(:call_recording, :pending, organization: org1) }

      it 'returns only completed recordings' do
        expect(CallRecording.completed).to include(completed_recording)
        expect(CallRecording.completed).not_to include(pending_recording)
      end
    end
  end

  describe '#transcribed?' do
    let(:recording) { create(:call_recording, organization: organization) }

    context 'when no transcriptions exist' do
      it 'returns false' do
        expect(recording.transcribed?).to be false
      end
    end

    context 'when completed transcription exists' do
      before do
        create(:call_transcription, call_recording: recording, status: 'completed')
      end

      it 'returns true' do
        expect(recording.transcribed?).to be true
      end
    end

    context 'when only failed transcription exists' do
      before do
        create(:call_transcription, call_recording: recording, status: 'failed')
      end

      it 'returns false' do
        expect(recording.transcribed?).to be false
      end
    end
  end

  describe '#latest_transcription' do
    let(:recording) { create(:call_recording, organization: organization) }

    it 'returns the most recent completed transcription' do
      old_transcription = create(:call_transcription, call_recording: recording, created_at: 1.hour.ago)
      latest_transcription = create(:call_transcription, call_recording: recording, created_at: 30.minutes.ago)

      expect(recording.latest_transcription).to eq(latest_transcription)
    end

    it 'returns nil when no completed transcriptions exist' do
      create(:call_transcription, :pending, call_recording: recording)
      expect(recording.latest_transcription).to be_nil
    end
  end

  describe '#mark_completed!' do
    let(:recording) { create(:call_recording, :pending, organization: organization) }

    it 'updates status to completed' do
      recording.mark_completed!
      expect(recording.reload.status).to eq('completed')
    end
  end

  describe '#mark_failed!' do
    let(:recording) { create(:call_recording, :processing, organization: organization) }

    it 'updates status to failed' do
      recording.mark_failed!
      expect(recording.reload.status).to eq('failed')
    end
  end
end