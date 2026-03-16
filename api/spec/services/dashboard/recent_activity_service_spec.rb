require 'rails_helper'

RSpec.describe Dashboard::RecentActivityService, type: :service do
  let!(:organization) { create(:organization) }
  let!(:course) { create(:course, organization: organization) }
  let!(:user) { create(:user, organization: organization) }
  let!(:tee_sheet) { create(:tee_sheet, course: course, date: Date.current) }
  let!(:tee_time) { create(:tee_time, tee_sheet: tee_sheet) }

  describe '#call' do
    context 'with valid params' do
      let(:service) { described_class.new(organization: organization) }

      before do
        # Create bookings with different statuses and updated_at times
        travel_to(2.hours.ago) do
          @confirmed_booking = create(:booking, :confirmed, 
                                     user: user, 
                                     tee_time: tee_time,
                                     updated_at: 2.hours.ago)
        end
        
        travel_to(1.hour.ago) do
          @cancelled_booking = create(:booking, :cancelled, 
                                     user: user, 
                                     tee_time: tee_time,
                                     updated_at: 1.hour.ago)
        end
        
        travel_to(30.minutes.ago) do
          @checked_in_booking = create(:booking, :checked_in, 
                                      user: user, 
                                      tee_time: tee_time,
                                      updated_at: 30.minutes.ago)
        end
        
        travel_to(10.minutes.ago) do
          @no_show_booking = create(:booking, :no_show, 
                                   user: user, 
                                   tee_time: tee_time,
                                   updated_at: 10.minutes.ago)
        end

        # Create an old booking outside 24-hour window
        travel_to(25.hours.ago) do
          @old_booking = create(:booking, :confirmed, 
                               user: user, 
                               tee_time: tee_time,
                               updated_at: 25.hours.ago)
        end
      end

      it 'returns success with activities sorted by updated_at DESC' do
        result = service.call

        expect(result).to be_success
        expect(result.activities.count).to eq(4)
        
        # Should be ordered from most recent to oldest
        activity_types = result.activities.map { |a| a[:activity_type] }
        expect(activity_types).to eq(['no_show', 'checked_in', 'cancelled', 'booked'])
        
        # Should include all required fields
        activity = result.activities.first
        expect(activity).to include(:id, :activity_type, :confirmation_code, :user_name, :course_name, :tee_time, :players_count, :occurred_at)
        expect(activity[:user_name]).to eq(user.full_name)
        expect(activity[:course_name]).to eq(course.name)
        expect(activity[:confirmation_code]).to eq(@no_show_booking.confirmation_code)
      end

      it 'excludes bookings older than 24 hours' do
        result = service.call
        
        expect(result).to be_success
        booking_ids = result.activities.map { |a| a[:id] }
        expect(booking_ids).not_to include(@old_booking.id)
      end

      it 'maps booking statuses to activity types correctly' do
        result = service.call

        activities_by_booking_id = result.activities.index_by { |a| a[:id] }
        
        expect(activities_by_booking_id[@confirmed_booking.id][:activity_type]).to eq('booked')
        expect(activities_by_booking_id[@cancelled_booking.id][:activity_type]).to eq('cancelled')
        expect(activities_by_booking_id[@checked_in_booking.id][:activity_type]).to eq('checked_in')
        expect(activities_by_booking_id[@no_show_booking.id][:activity_type]).to eq('no_show')
      end

      context 'when course_id is provided' do
        let(:other_course) { create(:course, organization: organization) }
        let(:other_tee_sheet) { create(:tee_sheet, course: other_course, date: Date.current) }
        let(:other_tee_time) { create(:tee_time, tee_sheet: other_tee_sheet) }
        let(:service) { described_class.new(organization: organization, course_id: course.id) }

        before do
          # Create booking on different course
          travel_to(1.hour.ago) do
            @other_course_booking = create(:booking, :confirmed,
                                          user: user,
                                          tee_time: other_tee_time,
                                          updated_at: 1.hour.ago)
          end
        end

        it 'filters activities by course_id' do
          result = service.call

          expect(result).to be_success
          expect(result.activities.count).to eq(4)
          
          course_names = result.activities.map { |a| a[:course_name] }.uniq
          expect(course_names).to eq([course.name])
        end
      end

      context 'when limit is provided' do
        let(:service) { described_class.new(organization: organization, limit: 2) }

        it 'respects the limit parameter' do
          result = service.call

          expect(result).to be_success
          expect(result.activities.count).to eq(2)
        end
      end
    end

    context 'with invalid params' do
      it 'returns failure when organization is nil' do
        service = described_class.new(organization: nil)
        result = service.call

        expect(result).to be_failure
        expect(result.errors).to include("Organization can't be blank")
      end

      it 'returns failure when limit is too large' do
        service = described_class.new(organization: organization, limit: 200)
        result = service.call

        expect(result).to be_failure
        expect(result.errors).to include("Limit must be less than or equal to 100")
      end

      it 'returns failure when limit is zero or negative' do
        service = described_class.new(organization: organization, limit: 0)
        result = service.call

        expect(result).to be_failure
        expect(result.errors).to include("Limit must be greater than 0")
      end
    end

    context 'when database error occurs' do
      let(:service) { described_class.new(organization: organization) }

      before do
        allow(Booking).to receive(:for_organization).and_raise(StandardError.new("Database error"))
      end

      it 'returns failure with error message' do
        result = service.call

        expect(result).to be_failure
        expect(result.errors.first).to include("Failed to fetch recent activity: Database error")
      end
    end
  end
end