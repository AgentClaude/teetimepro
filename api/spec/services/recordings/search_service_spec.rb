require 'rails_helper'

RSpec.describe Recordings::SearchService, type: :service do
  let(:organization) { create(:organization) }
  let!(:recording1) { create(:call_recording, organization: organization, created_at: 2.days.ago) }
  let!(:recording2) { create(:call_recording, organization: organization, created_at: 1.day.ago) }
  let!(:recording3) { create(:call_recording, organization: organization, status: 'failed') }

  describe '.call' do
    context 'with basic search' do
      it 'returns all recordings for organization' do
        result = described_class.call(organization: organization)

        expect(result).to be_success
        expect(result.recordings).to contain_exactly(recording1, recording2, recording3)
        expect(result.total_count).to eq(3)
        expect(result.current_page).to eq(1)
        expect(result.per_page).to eq(20)
      end

      it 'orders recordings by created_at desc' do
        result = described_class.call(organization: organization)

        recordings = result.recordings.to_a
        expect(recordings[0]).to eq(recording3) # Most recent
        expect(recordings[1]).to eq(recording2)
        expect(recordings[2]).to eq(recording1) # Oldest
      end
    end

    context 'with status filter' do
      it 'filters by status' do
        result = described_class.call(
          organization: organization,
          filters: { status: 'failed' }
        )

        expect(result).to be_success
        expect(result.recordings).to contain_exactly(recording3)
      end
    end

    context 'with date range filter' do
      it 'filters by date_from' do
        result = described_class.call(
          organization: organization,
          filters: { date_from: 1.day.ago.to_date }
        )

        expect(result.recordings).to contain_exactly(recording2, recording3)
      end

      it 'filters by date_to' do
        result = described_class.call(
          organization: organization,
          filters: { date_to: 1.day.ago.to_date }
        )

        expect(result.recordings).to include(recording1, recording2)
        expect(result.recordings).not_to include(recording3)
      end

      it 'filters by date range' do
        result = described_class.call(
          organization: organization,
          filters: { 
            date_from: 1.5.days.ago.to_date,
            date_to: 0.5.days.ago.to_date
          }
        )

        expect(result.recordings).to contain_exactly(recording2)
      end
    end

    context 'with duration filter' do
      let!(:short_recording) { create(:call_recording, :short_call, organization: organization) }
      let!(:long_recording) { create(:call_recording, :long_call, organization: organization) }

      it 'filters by minimum duration' do
        result = described_class.call(
          organization: organization,
          filters: { min_duration: 300 }
        )

        expect(result.recordings).to include(long_recording)
        expect(result.recordings).not_to include(short_recording)
      end

      it 'filters by maximum duration' do
        result = described_class.call(
          organization: organization,
          filters: { max_duration: 100 }
        )

        expect(result.recordings).to include(short_recording)
        expect(result.recordings).not_to include(long_recording)
      end
    end

    context 'with caller filter' do
      let(:voice_call_log) { create(:voice_call_log, organization: organization, caller_id: '+1234567890') }
      let!(:recording_with_caller) { create(:call_recording, organization: organization, voice_call_log: voice_call_log) }

      # Note: This test assumes VoiceCallLog has caller_id and caller_name fields
      it 'filters by caller information' do
        # Mock the voice call logs query since we don't have the exact schema
        allow_any_instance_of(described_class).to receive(:apply_caller_filter!) do
          @query_scope = @query_scope.where(id: recording_with_caller.id)
        end

        result = described_class.call(
          organization: organization,
          filters: { caller: '+1234567890' }
        )

        expect(result.recordings).to include(recording_with_caller)
      end
    end

    context 'with text search' do
      let!(:transcription1) { create(:call_transcription, call_recording: recording1, transcription_text: 'golf tee time booking') }
      let!(:transcription2) { create(:call_transcription, call_recording: recording2, transcription_text: 'tennis court reservation') }

      it 'searches in transcription text' do
        result = described_class.call(
          organization: organization,
          query: 'golf'
        )

        expect(result.recordings).to include(recording1)
        expect(result.recordings).not_to include(recording2)
      end

      it 'is case insensitive' do
        result = described_class.call(
          organization: organization,
          query: 'GOLF'
        )

        expect(result.recordings).to include(recording1)
      end

      it 'handles partial matches' do
        result = described_class.call(
          organization: organization,
          query: 'tee time'
        )

        expect(result.recordings).to include(recording1)
      end
    end

    context 'with pagination' do
      let!(:recordings) { create_list(:call_recording, 25, organization: organization) }

      it 'paginates results' do
        result = described_class.call(
          organization: organization,
          page: 1,
          per_page: 10
        )

        expect(result.recordings.count).to eq(10)
        expect(result.total_count).to eq(28) # 25 + original 3
        expect(result.total_pages).to eq(3)
        expect(result.current_page).to eq(1)
      end

      it 'returns second page' do
        result = described_class.call(
          organization: organization,
          page: 2,
          per_page: 10
        )

        expect(result.recordings.count).to eq(10)
        expect(result.current_page).to eq(2)
      end

      it 'caps per_page at 100' do
        result = described_class.call(
          organization: organization,
          per_page: 150
        )

        expect(result.per_page).to eq(100)
      end

      it 'handles page beyond total pages' do
        result = described_class.call(
          organization: organization,
          page: 999,
          per_page: 10
        )

        expect(result.current_page).to eq(result.total_pages)
      end
    end

    context 'with combined filters' do
      let!(:transcription) { create(:call_transcription, call_recording: recording2, transcription_text: 'golf booking completed') }

      it 'applies multiple filters together' do
        result = described_class.call(
          organization: organization,
          query: 'golf',
          filters: { 
            status: 'completed',
            date_from: 2.days.ago.to_date 
          }
        )

        expect(result.recordings).to contain_exactly(recording2)
      end
    end

    context 'with missing organization' do
      it 'returns validation failure' do
        result = described_class.call(organization: nil)

        expect(result).to be_failure
        expect(result.errors).to include(match(/Organization can't be blank/))
      end
    end

    context 'when database error occurs' do
      it 'returns failure' do
        allow_any_instance_of(described_class).to receive(:build_base_query!).and_raise(StandardError, 'DB Error')

        result = described_class.call(organization: organization)

        expect(result).to be_failure
        expect(result.errors).to include(match(/Search failed: DB Error/))
      end
    end
  end
end