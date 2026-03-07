require 'rails_helper'

RSpec.describe CallTranscription, type: :model do
  let(:organization) { create(:organization) }
  let(:call_recording) { create(:call_recording, organization: organization) }

  describe 'associations' do
    it { should belong_to(:organization) }
    it { should belong_to(:call_recording) }
    it { should belong_to(:voice_call_log).optional }
  end

  describe 'validations' do
    subject { build(:call_transcription, organization: organization, call_recording: call_recording) }

    it { should validate_presence_of(:transcription_text) }
    it { should validate_presence_of(:confidence_score) }
    it { should validate_presence_of(:language) }
    it { should validate_presence_of(:provider) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:word_count) }
    it { should validate_presence_of(:duration_seconds) }

    it { should validate_numericality_of(:confidence_score).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:confidence_score).is_less_than_or_equal_to(1) }
    it { should validate_numericality_of(:word_count).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:duration_seconds).is_greater_than(0) }

    it { should validate_inclusion_of(:provider).in_array(%w[deepgram whisper]) }
    it { should validate_inclusion_of(:status).in_array(%w[pending processing completed failed]) }
  end

  describe 'scopes' do
    let!(:org1) { create(:organization) }
    let!(:org2) { create(:organization) }
    let!(:recording1) { create(:call_recording, organization: org1) }
    let!(:recording2) { create(:call_recording, organization: org2) }
    let!(:transcription1) { create(:call_transcription, organization: org1, call_recording: recording1) }
    let!(:transcription2) { create(:call_transcription, organization: org2, call_recording: recording2) }

    describe '.for_organization' do
      it 'returns transcriptions for the specified organization' do
        expect(CallTranscription.for_organization(org1)).to contain_exactly(transcription1)
      end
    end

    describe '.search_text' do
      let!(:golf_transcription) { create(:call_transcription, organization: org1, transcription_text: 'I want to book a golf tee time', call_recording: recording1) }
      let!(:tennis_transcription) { create(:call_transcription, organization: org1, transcription_text: 'I want to book a tennis court', call_recording: create(:call_recording, organization: org1)) }

      it 'finds transcriptions containing the search term' do
        results = CallTranscription.search_text('golf')
        expect(results).to include(golf_transcription)
        expect(results).not_to include(tennis_transcription)
      end

      it 'is case insensitive' do
        results = CallTranscription.search_text('GOLF')
        expect(results).to include(golf_transcription)
      end
    end

    describe '.by_provider' do
      let!(:deepgram_transcription) { create(:call_transcription, provider: 'deepgram', organization: org1, call_recording: recording1) }
      let!(:whisper_transcription) { create(:call_transcription, provider: 'whisper', organization: org1, call_recording: create(:call_recording, organization: org1)) }

      it 'filters by provider' do
        expect(CallTranscription.by_provider('deepgram')).to include(deepgram_transcription)
        expect(CallTranscription.by_provider('deepgram')).not_to include(whisper_transcription)
      end
    end
  end

  describe 'confidence methods' do
    describe '#high_confidence?' do
      it 'returns true for confidence >= 0.8' do
        transcription = build(:call_transcription, confidence_score: 0.85)
        expect(transcription.high_confidence?).to be true
      end

      it 'returns false for confidence < 0.8' do
        transcription = build(:call_transcription, confidence_score: 0.75)
        expect(transcription.high_confidence?).to be false
      end
    end

    describe '#medium_confidence?' do
      it 'returns true for confidence between 0.6 and 0.8' do
        transcription = build(:call_transcription, confidence_score: 0.7)
        expect(transcription.medium_confidence?).to be true
      end

      it 'returns false for confidence >= 0.8' do
        transcription = build(:call_transcription, confidence_score: 0.9)
        expect(transcription.medium_confidence?).to be false
      end

      it 'returns false for confidence < 0.6' do
        transcription = build(:call_transcription, confidence_score: 0.5)
        expect(transcription.medium_confidence?).to be false
      end
    end

    describe '#low_confidence?' do
      it 'returns true for confidence < 0.6' do
        transcription = build(:call_transcription, confidence_score: 0.4)
        expect(transcription.low_confidence?).to be true
      end

      it 'returns false for confidence >= 0.6' do
        transcription = build(:call_transcription, confidence_score: 0.7)
        expect(transcription.low_confidence?).to be false
      end
    end
  end

  describe '#formatted_duration' do
    it 'formats duration in MM:SS format' do
      transcription = build(:call_transcription, duration_seconds: 125)
      expect(transcription.formatted_duration).to eq('2:05')
    end

    it 'pads seconds with zero when needed' do
      transcription = build(:call_transcription, duration_seconds: 65)
      expect(transcription.formatted_duration).to eq('1:05')
    end
  end

  describe 'callbacks' do
    describe 'calculate_word_count' do
      it 'calculates word count from transcription text' do
        transcription = create(:call_transcription, 
          transcription_text: 'Hello world this is a test', 
          call_recording: call_recording
        )
        expect(transcription.word_count).to eq(6)
      end

      it 'handles empty transcription text' do
        transcription = build(:call_transcription, 
          transcription_text: '', 
          call_recording: call_recording
        )
        transcription.valid?
        expect(transcription.word_count).to eq(0)
      end
    end

    describe 'calculate_duration_from_recording' do
      it 'sets duration from call_recording when not provided' do
        recording = create(:call_recording, duration_seconds: 180, organization: organization)
        transcription = build(:call_transcription, 
          call_recording: recording, 
          duration_seconds: nil
        )
        transcription.valid?
        expect(transcription.duration_seconds).to eq(180)
      end
    end
  end
end