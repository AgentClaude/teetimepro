require 'rails_helper'

RSpec.describe Voice::ConfirmVoiceBookingService, type: :service do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.current + 1.day) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, price_cents: 5000) }
  let(:user) { create(:user, organization: organization) }
  let(:pending_booking) do
    create(:booking, 
           tee_time: tee_time, 
           user: user, 
           players_count: 2, 
           status: :pending_voice_confirmation,
           total_cents: 10000)
  end
  
  let(:valid_params) do
    {
      organization: organization,
      booking_id: pending_booking.id
    }
  end

  describe '#call' do
    context 'with valid parameters' do
      it 'confirms the pending booking successfully' do
        result = described_class.call(valid_params)

        expect(result.success?).to be true
        expect(result.booking.status).to eq('confirmed')
        expect(result.booking.notes).to eq('Voice booking confirmed')
      end

      it 'returns confirmed booking details' do
        result = described_class.call(valid_params)

        expect(result.success?).to be true
        expect(result.booking_id).to eq(pending_booking.id)
        expect(result.confirmation_code).to eq(pending_booking.confirmation_code)
        expect(result.status).to eq('confirmed')
        expect(result.date).to eq(tee_time.starts_at.strftime("%Y-%m-%d"))
        expect(result.formatted_time).to eq(tee_time.formatted_time)
        expect(result.players).to eq(2)
        expect(result.total_cents).to eq(10000)
        expect(result.course_name).to eq(course.name)
      end

      it 'preserves all booking attributes except status and notes' do
        original_confirmation_code = pending_booking.confirmation_code
        original_total_cents = pending_booking.total_cents
        original_players_count = pending_booking.players_count
        
        result = described_class.call(valid_params)

        booking = result.booking.reload
        expect(booking.confirmation_code).to eq(original_confirmation_code)
        expect(booking.total_cents).to eq(original_total_cents)
        expect(booking.players_count).to eq(original_players_count)
        expect(booking.tee_time).to eq(tee_time)
        expect(booking.user).to eq(user)
      end
    end

    context 'with invalid parameters' do
      it 'fails when organization is missing' do
        params = valid_params.except(:organization)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Organization can't be blank")
      end

      it 'fails when booking_id is missing' do
        params = valid_params.except(:booking_id)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Booking id can't be blank")
      end
    end

    context 'when booking is not found or invalid' do
      it 'fails when booking does not exist' do
        params = valid_params.merge(booking_id: 99999)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Booking not found or not in pending state")
      end

      it 'fails when booking belongs to different organization' do
        other_org = create(:organization)
        other_course = create(:course, organization: other_org)
        other_tee_sheet = create(:tee_sheet, course: other_course)
        other_tee_time = create(:tee_time, tee_sheet: other_tee_sheet)
        other_user = create(:user, organization: other_org)
        other_booking = create(:booking, 
                              tee_time: other_tee_time, 
                              user: other_user, 
                              status: :pending_voice_confirmation)
        
        params = valid_params.merge(booking_id: other_booking.id)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Booking not found or not in pending state")
      end

      it 'fails when booking is not in pending state' do
        pending_booking.update!(status: :confirmed)
        
        result = described_class.call(valid_params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Booking not found or not in pending state")
      end

      it 'fails when booking is cancelled' do
        pending_booking.update!(status: :cancelled)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Booking not found or not in pending state")
      end
    end

    context 'when booking is expired' do
      it 'auto-cancels expired pending booking and fails' do
        pending_booking.update!(created_at: 6.minutes.ago)
        
        result = described_class.call(valid_params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Booking not found or not in pending state")
        
        # Check that booking was auto-cancelled
        pending_booking.reload
        expect(pending_booking.status).to eq('cancelled')
        expect(pending_booking.cancellation_reason).to eq("Voice booking timeout - not confirmed within 5 minutes")
      end

      it 'does not cancel booking that is exactly 5 minutes old' do
        pending_booking.update!(created_at: 5.minutes.ago)
        
        result = described_class.call(valid_params)
        
        expect(result.success?).to be true
        expect(result.booking.status).to eq('confirmed')
      end
    end

    context 'when tee time is no longer available' do
      it 'fails when tee time is in the past' do
        tee_time.update!(starts_at: 1.hour.ago)
        
        result = described_class.call(valid_params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("This tee time is no longer available - it's in the past")
      end

      it 'fails when tee time no longer has enough spots' do
        # Book the remaining spots
        other_user = create(:user, organization: organization)
        remaining_spots = tee_time.available_spots - pending_booking.players_count
        create(:booking, tee_time: tee_time, user: other_user, players_count: remaining_spots + 1)
        
        result = described_class.call(valid_params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("This tee time is no longer available - insufficient spots")
      end

      it 'succeeds when there are exactly enough spots' do
        # Book some spots but leave exactly enough for this booking
        other_user = create(:user, organization: organization)
        remaining_spots = tee_time.available_spots - pending_booking.players_count
        create(:booking, tee_time: tee_time, user: other_user, players_count: remaining_spots) if remaining_spots > 0
        
        result = described_class.call(valid_params)
        
        expect(result.success?).to be true
        expect(result.booking.status).to eq('confirmed')
      end
    end

    context 'when database error occurs' do
      it 'handles transaction rollback gracefully' do
        allow_any_instance_of(Booking).to receive(:save).and_return(false)
        allow_any_instance_of(Booking).to receive(:errors).and_return(double(full_messages: ["Database error"]))
        
        result = described_class.call(valid_params)
        
        expect(result.failure?).to be true
        expect(result.errors).to be_present
      end

      it 'handles standard errors gracefully' do
        allow_any_instance_of(described_class).to receive(:find_and_validate_booking).and_raise(StandardError.new("Database connection failed"))
        
        result = described_class.call(valid_params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Failed to confirm voice booking: Database connection failed")
      end
    end
  end
end