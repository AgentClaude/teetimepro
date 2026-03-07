require 'rails_helper'

RSpec.describe Voice::AnalyticsService, type: :service do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:start_date) { 7.days.ago.to_date }
  let(:end_date) { Date.current }
  let(:service) { described_class.new(organization: organization, start_date: start_date, end_date: end_date) }

  describe '#call' do
    context 'with valid parameters' do
      before do
        # Create test data
        3.times do
          create(:voice_call_log, 
                 organization: organization, 
                 course: course,
                 status: 'completed',
                 duration_seconds: 120,
                 channel: 'browser',
                 started_at: 2.days.ago)
        end
        
        2.times do
          create(:voice_call_log, 
                 organization: organization, 
                 course: course,
                 status: 'error',
                 channel: 'twilio',
                 started_at: 1.day.ago)
        end
        
        # Create a call that resulted in a booking
        call_with_booking = create(:voice_call_log, 
                                   organization: organization, 
                                   course: course,
                                   status: 'completed',
                                   duration_seconds: 180,
                                   channel: 'browser',
                                   started_at: 1.day.ago)
        
        # Mock the booking_created? method to return true for this call
        allow_any_instance_of(VoiceCallLog).to receive(:booking_created?).and_return(false)
        allow(call_with_booking).to receive(:booking_created?).and_return(true)
      end

      it 'returns success result' do
        result = service.call
        expect(result).to be_success
      end

      it 'calculates total calls correctly' do
        result = service.call
        expect(result.total_calls).to eq(6)
      end

      it 'calculates completed calls correctly' do
        result = service.call
        expect(result.completed_calls).to eq(4)
      end

      it 'calculates error rate correctly' do
        result = service.call
        expect(result.error_rate).to eq(33.33) # 2 errors out of 6 total calls
      end

      it 'calculates average duration correctly' do
        result = service.call
        # Average of 120, 120, 120, 180 = 135 seconds
        expect(result.average_duration_seconds).to eq(135)
      end

      it 'returns calls by channel data' do
        result = service.call
        channel_data = result.calls_by_channel
        
        browser_stats = channel_data.find { |c| c[:channel] == 'browser' }
        twilio_stats = channel_data.find { |c| c[:channel] == 'twilio' }
        
        expect(browser_stats[:count]).to eq(4)
        expect(twilio_stats[:count]).to eq(2)
      end

      it 'returns calls by day data' do
        result = service.call
        daily_data = result.calls_by_day
        
        expect(daily_data.length).to eq(8) # 7 days + today
        
        # Should have data for the days with calls
        calls_2_days_ago = daily_data.find { |d| d[:date] == 2.days.ago.to_date }
        calls_1_day_ago = daily_data.find { |d| d[:date] == 1.day.ago.to_date }
        
        expect(calls_2_days_ago[:count]).to eq(3)
        expect(calls_1_day_ago[:count]).to eq(3)
      end
    end

    context 'with course_id filter' do
      let(:other_course) { create(:course, organization: organization) }
      let(:service) { described_class.new(organization: organization, course_id: course.id, start_date: start_date, end_date: end_date) }

      before do
        # Calls for the target course
        create(:voice_call_log, organization: organization, course: course, started_at: 1.day.ago)
        create(:voice_call_log, organization: organization, course: course, started_at: 1.day.ago)
        
        # Calls for other course (should be filtered out)
        create(:voice_call_log, organization: organization, course: other_course, started_at: 1.day.ago)
      end

      it 'only includes calls for the specified course' do
        result = service.call
        expect(result.total_calls).to eq(2)
      end
    end

    context 'with missing required parameters' do
      let(:service) { described_class.new(organization: organization) }

      it 'returns validation failure' do
        result = service.call
        expect(result).not_to be_success
        expect(result.errors).to include("Start date can't be blank")
        expect(result.errors).to include("End date can't be blank")
      end
    end

    context 'when database error occurs' do
      before do
        allow(VoiceCallLog).to receive(:for_organization).and_raise(StandardError.new("Database error"))
      end

      it 'handles errors gracefully' do
        result = service.call
        expect(result).not_to be_success
        expect(result.errors.first).to include("Failed to generate voice analytics")
      end
    end

    context 'with no data' do
      it 'returns zero values when no calls exist' do
        result = service.call
        
        expect(result.total_calls).to eq(0)
        expect(result.completed_calls).to eq(0)
        expect(result.error_rate).to eq(0.0)
        expect(result.average_duration_seconds).to eq(0)
        expect(result.booking_conversion_rate).to eq(0.0)
        expect(result.calls_by_channel).to eq([])
        expect(result.calls_by_day.length).to eq(8) # Still returns full date range with 0 counts
      end
    end
  end
end