require 'rails_helper'

RSpec.describe Voice::CancelVoiceBookingService, type: :service do
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
      booking_id: pending_booking.id,
      reason: "Caller changed their mind"
    }
  end

  describe '#call' do
    context 'with valid parameters' do
      it 'cancels the pending booking successfully' do
        result = described_class.call(valid_params)

        expect(result.success?).to be true
        expect(result.booking.status).to eq('cancelled')
        expect(result.booking.cancelled_at).to be_within(5.seconds).of(Time.current)
        expect(result.booking.cancellation_reason).to eq("Caller changed their mind")
        expect(result.booking.notes).to eq('Voice booking cancelled during confirmation')
      end

      it 'returns cancelled booking details' do
        result = described_class.call(valid_params)

        expect(result.success?).to be true
        expect(result.booking_id).to eq(pending_booking.id)
        expect(result.confirmation_code).to eq(pending_booking.confirmation_code)
        expect(result.status).to eq('cancelled')
        expect(result.cancelled_at).to be_present
        expect(result.cancellation_reason).to eq("Caller changed their mind")
        expect(result.date).to eq(tee_time.starts_at.strftime("%Y-%m-%d"))
        expect(result.formatted_time).to eq(tee_time.formatted_time)
        expect(result.players).to eq(2)
        expect(result.course_name).to eq(course.name)
      end

      it 'uses default cancellation reason when none provided' do
        params = valid_params.except(:reason)
        
        result = described_class.call(params)

        expect(result.success?).to be true
        expect(result.booking.cancellation_reason).to eq("Voice booking cancelled by caller")
        expect(result.cancellation_reason).to eq("Voice booking cancelled by caller")
      end

      it 'handles empty reason string' do
        params = valid_params.merge(reason: "")
        
        result = described_class.call(params)

        expect(result.success?).to be true
        expect(result.booking.cancellation_reason).to eq("Voice booking cancelled by caller")
      end

      it 'handles whitespace-only reason' do
        params = valid_params.merge(reason: "   ")
        
        result = described_class.call(params)

        expect(result.success?).to be true
        expect(result.booking.cancellation_reason).to eq("Voice booking cancelled by caller")
      end

      it 'preserves all booking attributes except status, cancelled_at, cancellation_reason, and notes' do
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
        expect(result.errors).to include("Booking can't be blank")
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

      it 'fails when booking is already cancelled' do
        pending_booking.update!(status: :cancelled)
        
        result = described_class.call(valid_params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Booking not found or not in pending state")
      end

      it 'fails when booking is completed' do
        pending_booking.update!(status: :completed)
        
        result = described_class.call(valid_params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Booking not found or not in pending state")
      end
    end

    context 'when database error occurs' do
      it 'handles transaction rollback gracefully' do
        # First create the booking normally to ensure it exists
        booking = pending_booking
        
        # Now mock the save method to fail only for updates (not creation)
        allow(booking).to receive(:save).and_return(false)
        
        # Create a proper errors mock that includes all necessary methods
        errors_mock = double("ActiveModel::Errors")
        allow(errors_mock).to receive(:full_messages).and_return(["Database error"])
        allow(errors_mock).to receive(:clear)
        allow(errors_mock).to receive(:uniq!)
        allow(errors_mock).to receive(:empty?).and_return(false)
        allow(errors_mock).to receive(:any?).and_return(true)
        allow(errors_mock).to receive(:count).and_return(1)
        allow(errors_mock).to receive(:size).and_return(1)
        allow(errors_mock).to receive(:length).and_return(1)
        
        allow(booking).to receive(:errors).and_return(errors_mock)
        
        # Mock the complex query chain used by find_and_validate_booking
        booking_relation_mock = double("ActiveRecord::Relation")
        allow(Booking).to receive(:joins).and_return(booking_relation_mock)
        allow(booking_relation_mock).to receive(:where).and_return(booking_relation_mock)
        allow(booking_relation_mock).to receive(:first).and_return(booking)
        
        result = described_class.call(valid_params)
        
        expect(result.failure?).to be true
        expect(result.errors).to be_present
      end

      it 'handles standard errors gracefully' do
        allow_any_instance_of(described_class).to receive(:find_and_validate_booking).and_raise(StandardError.new("Database connection failed"))
        
        result = described_class.call(valid_params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Failed to cancel voice booking: Database connection failed")
      end
    end

    context 'with custom reason messages' do
      it 'handles long reason messages' do
        long_reason = "A" * 500
        params = valid_params.merge(reason: long_reason)
        
        result = described_class.call(params)
        
        expect(result.success?).to be true
        expect(result.booking.cancellation_reason).to eq(long_reason)
        expect(result.cancellation_reason).to eq(long_reason)
      end

      it 'handles reason with special characters' do
        special_reason = "Caller said 'Actually, I'll call back later' — changed plans!"
        params = valid_params.merge(reason: special_reason)
        
        result = described_class.call(params)
        
        expect(result.success?).to be true
        expect(result.booking.cancellation_reason).to eq(special_reason)
        expect(result.cancellation_reason).to eq(special_reason)
      end
    end
  end
end