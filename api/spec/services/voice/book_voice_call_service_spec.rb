require 'rails_helper'

RSpec.describe Voice::BookVoiceCallService, type: :service do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.current + 1.day) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, price_cents: 5000) }
  
  let(:valid_params) do
    {
      organization: organization,
      tee_time_id: tee_time.id,
      players_count: 2,
      caller_name: "John Doe",
      caller_phone: "+15551234567"
    }
  end

  describe '#call' do
    context 'with valid parameters' do
      it 'creates a new voice booking successfully' do
        expect {
          result = described_class.call(valid_params)
          expect(result.success?).to be true
        }.to change { Booking.count }.by(1)
          .and change { User.count }.by(1)
      end

      it 'creates booking with pending_voice_confirmation status' do
        result = described_class.call(valid_params)

        expect(result.success?).to be true
        expect(result.booking).to be_a(Booking)
        expect(result.booking.status).to eq('pending_voice_confirmation')
        expect(result.booking.players_count).to eq(2)
        expect(result.booking.total_cents).to eq(10000) # 2 players * 5000 cents
      end

      it 'returns booking details for voice agent' do
        result = described_class.call(valid_params)

        expect(result.success?).to be true
        expect(result.booking_id).to eq(result.booking.id)
        expect(result.confirmation_code).to be_present
        expect(result.date).to eq(tee_time.starts_at.strftime("%Y-%m-%d"))
        expect(result.formatted_time).to eq(tee_time.formatted_time)
        expect(result.players).to eq(2)
        expect(result.price_per_player_cents).to eq(5000)
        expect(result.total_cents).to eq(10000)
        expect(result.course_name).to eq(course.name)
      end

      it 'creates new user with normalized phone number' do
        result = described_class.call(valid_params)

        user = result.booking.user
        expect(user.first_name).to eq("John")
        expect(user.last_name).to eq("Doe")
        expect(user.phone).to eq("+15551234567")
        expect(user.email).to eq("15551234567@voice-booking.local")
        expect(user.role).to eq("golfer")
        expect(user.organization).to eq(organization)
        expect(user.confirmed_at).to be_present
      end

      it 'handles single name correctly' do
        params = valid_params.merge(caller_name: "Madonna")
        
        result = described_class.call(params)

        user = result.booking.user
        expect(user.first_name).to eq("Madonna")
        expect(user.last_name).to eq("")
      end

      it 'normalizes phone numbers correctly' do
        params = valid_params.merge(caller_phone: "5551234567")
        
        result = described_class.call(params)

        user = result.booking.user
        expect(user.phone).to eq("+15551234567")
        expect(user.email).to eq("15551234567@voice-booking.local")
      end

      it 'handles 11-digit US numbers' do
        params = valid_params.merge(caller_phone: "15551234567")
        
        result = described_class.call(params)

        user = result.booking.user
        expect(user.phone).to eq("+15551234567")
      end

      it 'finds existing user by phone' do
        existing_user = create(:user, organization: organization, phone: "+15551234567")
        
        expect {
          result = described_class.call(valid_params)
          expect(result.success?).to be true
        }.to change { Booking.count }.by(1)
          .and change { User.count }.by(0) # No new user created

        expect(result.booking.user).to eq(existing_user)
      end

      it 'handles tee time with no price' do
        tee_time.update!(price_cents: nil)
        
        result = described_class.call(valid_params)

        expect(result.success?).to be true
        expect(result.booking.total_cents).to eq(0)
        expect(result.price_per_player_cents).to eq(0)
        expect(result.total_cents).to eq(0)
      end
    end

    context 'with invalid parameters' do
      it 'fails when organization is missing' do
        params = valid_params.except(:organization)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Organization can't be blank")
      end

      it 'fails when tee_time_id is missing' do
        params = valid_params.except(:tee_time_id)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Tee time id can't be blank")
      end

      it 'fails when players_count is missing' do
        params = valid_params.except(:players_count)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Players count can't be blank")
      end

      it 'fails when players_count is invalid' do
        params = valid_params.merge(players_count: 6)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Players count must be in 1..5")
      end

      it 'fails when caller_name is missing' do
        params = valid_params.except(:caller_name)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Caller name can't be blank")
      end

      it 'fails when caller_phone is missing' do
        params = valid_params.except(:caller_phone)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Caller phone can't be blank")
      end
    end

    context 'when tee time is not available' do
      it 'fails when tee time does not exist' do
        params = valid_params.merge(tee_time_id: 99999)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Tee time not found or unavailable")
      end

      it 'fails when tee time belongs to different organization' do
        other_org = create(:organization)
        other_course = create(:course, organization: other_org)
        other_tee_sheet = create(:tee_sheet, course: other_course)
        other_tee_time = create(:tee_time, tee_sheet: other_tee_sheet)
        
        params = valid_params.merge(tee_time_id: other_tee_time.id)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Tee time not found or unavailable")
      end

      it 'fails when tee time does not have enough available spots' do
        # Book the tee time partially
        user = create(:user, organization: organization)
        create(:booking, tee_time: tee_time, user: user, players_count: tee_time.max_players - 1)
        
        result = described_class.call(valid_params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Tee time not found or unavailable")
      end

      it 'fails when tee time is in the past' do
        tee_time.update!(starts_at: 1.hour.ago)
        
        result = described_class.call(valid_params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Tee time not found or unavailable")
      end
    end

    context 'when database error occurs' do
      it 'handles transaction rollback gracefully' do
        allow(Booking).to receive(:new).and_raise(ActiveRecord::RecordInvalid)
        
        result = described_class.call(valid_params)
        
        expect(result.failure?).to be true
        expect(result.errors).to be_present
      end

      it 'handles standard errors gracefully' do
        allow_any_instance_of(described_class).to receive(:find_and_validate_tee_time).and_raise(StandardError.new("Database connection failed"))
        
        result = described_class.call(valid_params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Failed to create voice booking: Database connection failed")
      end
    end
  end
end