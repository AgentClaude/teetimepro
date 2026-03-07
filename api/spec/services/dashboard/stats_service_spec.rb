require 'rails_helper'

RSpec.describe Dashboard::StatsService, type: :service do
  let!(:organization) { create(:organization) }
  let!(:course) { create(:course, organization: organization) }
  let!(:other_course) { create(:course, organization: organization) }
  let!(:today) { Date.current }
  let!(:yesterday) { today - 1.day }
  
  let!(:user1) { create(:user, organization: organization, role: :golfer) }
  let!(:user2) { create(:user, organization: organization, role: :staff) }

  # Create tee sheet and tee time for today
  let!(:tee_sheet_today) { create(:tee_sheet, course: course, date: today) }
  let!(:tee_time_today) { create(:tee_time, tee_sheet: tee_sheet_today, starts_at: 2.hours.from_now) }
  
  # Create tee sheet and tee time for yesterday
  let!(:tee_sheet_yesterday) { create(:tee_sheet, course: course, date: yesterday) }
  let!(:tee_time_yesterday) { create(:tee_time, tee_sheet: tee_sheet_yesterday, starts_at: yesterday + 10.hours) }

  # Create bookings
  let!(:confirmed_booking_today) { 
    create(:booking, tee_time: tee_time_today, user: user1, status: :confirmed, total_cents: 5000) 
  }
  let!(:completed_booking_yesterday) { 
    create(:booking, tee_time: tee_time_yesterday, user: user2, status: :completed, total_cents: 7500) 
  }
  let!(:cancelled_booking_today) { 
    create(:booking, tee_time: tee_time_today, user: user1, status: :cancelled, total_cents: 4000) 
  }

  describe '#call' do
    context 'with valid organization' do
      subject { described_class.call(organization: organization, date: today) }

      it 'returns success result' do
        expect(subject).to be_success
      end

      it 'returns correct todays bookings count' do
        expect(subject.data[:todays_bookings]).to eq(1) # Only confirmed booking for today
      end

      it 'returns correct todays revenue' do
        expect(subject.data[:todays_revenue_cents]).to eq(5000) # Only confirmed booking
      end

      it 'returns correct active members count' do
        expect(subject.data[:active_members]).to eq(2) # Both users have bookings
      end

      it 'returns utilization percentage' do
        expect(subject.data[:utilization_percentage]).to be_a(Float)
      end

      it 'returns upcoming bookings data' do
        upcoming = subject.data[:upcoming_bookings]
        expect(upcoming).to be_an(Array)
        expect(upcoming.length).to eq(1) # Only future booking
        
        booking_data = upcoming.first
        expect(booking_data[:id]).to eq(confirmed_booking_today.id)
        expect(booking_data[:confirmation_code]).to eq(confirmed_booking_today.confirmation_code)
        expect(booking_data[:user_name]).to eq(user1.full_name)
        expect(booking_data[:course_name]).to eq(course.name)
      end

      it 'returns weekly revenue data' do
        weekly_data = subject.data[:weekly_revenue]
        expect(weekly_data).to be_an(Array)
        expect(weekly_data.length).to eq(7) # Last 7 days
        
        # Check today's data
        today_data = weekly_data.find { |d| d[:date] == today }
        expect(today_data[:revenue_cents]).to eq(5000)
        
        # Check yesterday's data
        yesterday_data = weekly_data.find { |d| d[:date] == yesterday }
        expect(yesterday_data[:revenue_cents]).to eq(7500)
      end
    end

    context 'with course filter' do
      let!(:other_tee_sheet) { create(:tee_sheet, course: other_course, date: today) }
      let!(:other_tee_time) { create(:tee_time, tee_sheet: other_tee_sheet, starts_at: 3.hours.from_now) }
      let!(:other_booking) { 
        create(:booking, tee_time: other_tee_time, user: user1, status: :confirmed, total_cents: 3000) 
      }

      subject { described_class.call(organization: organization, course_id: course.id, date: today) }

      it 'filters bookings by course' do
        expect(subject.data[:todays_bookings]).to eq(1) # Only main course booking
        expect(subject.data[:todays_revenue_cents]).to eq(5000) # Only main course revenue
      end
    end

    context 'with no data' do
      let!(:empty_organization) { create(:organization) }
      
      subject { described_class.call(organization: empty_organization, date: today) }

      it 'returns zero values' do
        expect(subject.data[:todays_bookings]).to eq(0)
        expect(subject.data[:todays_revenue_cents]).to eq(0)
        expect(subject.data[:active_members]).to eq(0)
        expect(subject.data[:utilization_percentage]).to eq(0.0)
        expect(subject.data[:upcoming_bookings]).to eq([])
      end
    end

    context 'with invalid organization' do
      subject { described_class.call(organization: nil) }

      it 'returns failure result' do
        expect(subject).not_to be_success
        expect(subject.errors).to include("Organization can't be blank")
      end
    end

    context 'when service raises error' do
      before do
        allow(Booking).to receive(:for_organization).and_raise(StandardError, "Database error")
      end

      subject { described_class.call(organization: organization) }

      it 'handles errors gracefully' do
        expect(subject).not_to be_success
        expect(subject.errors.first).to include("Failed to generate dashboard stats")
      end
    end
  end
end