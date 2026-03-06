require "rails_helper"

RSpec.describe Api::V1::BookingsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:api_key) { create(:api_key, organization: organization) }
  let(:headers) { { "Authorization" => "Bearer #{api_key.display_key}" } }

  def json_response
    JSON.parse(response.body)
  end

  def make_request
    request.headers.merge!(headers) if headers.present?
    send(http_method, action, params: params)
  end

  describe "GET #index" do
    let(:http_method) { :get }
    let(:action) { :index }
    let(:params) { {} }
    
    let(:course) { create(:course, organization: organization) }
    let(:tee_sheet) { create(:tee_sheet, course: course) }
    let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet) }
    let!(:booking) { create(:booking, tee_time: tee_time) }
    let!(:other_org_booking) { create(:booking) } # Different organization

    context "with valid API key" do
      it "returns bookings for the organization" do
        make_request
        
        expect(response).to have_http_status(:ok)
        expect(json_response["data"]).to be_an(Array)
        expect(json_response["data"].length).to eq(1)
        expect(json_response["data"].first["id"]).to eq(booking.id)
      end

      it "includes booking details with nested data" do
        make_request
        
        booking_data = json_response["data"].first
        expect(booking_data).to include(
          "id",
          "confirmation_code",
          "status",
          "players_count",
          "total",
          "tee_time",
          "course",
          "user"
        )
        expect(booking_data["tee_time"]).to include("id", "starts_at")
        expect(booking_data["course"]).to include("id", "name")
      end
    end

    include_examples "API authentication"
    include_examples "API pagination"
  end

  describe "POST #create" do
    let(:http_method) { :post }
    let(:action) { :create }
    
    let(:course) { create(:course, organization: organization) }
    let(:tee_sheet) { create(:tee_sheet, course: course) }
    let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, status: :available) }
    let(:user) { create(:user, organization: organization) }
    
    let(:params) do
      {
        booking: {
          tee_time_id: tee_time.id,
          players_count: 2,
          user: {
            email: user.email,
            first_name: user.first_name,
            last_name: user.last_name,
            phone: user.phone
          },
          player_names: ["John Doe", "Jane Smith"]
        }
      }
    end

    before do
      # Mock the service to avoid complex setup
      allow(Bookings::CreateBookingService).to receive(:call).and_return(
        double(
          success?: true,
          booking: double(
            id: 123,
            confirmation_code: "ABC123",
            status: "confirmed",
            players_count: 2,
            total: double(format: "50.00"),
            total_cents: 5000,
            notes: "",
            tee_time: tee_time,
            course: course,
            user: user,
            booking_players: [],
            created_at: Time.current,
            updated_at: Time.current
          )
        )
      )
    end

    context "with valid parameters" do
      it "creates a booking successfully" do
        make_request
        
        expect(response).to have_http_status(:created)
        expect(json_response["id"]).to eq(123)
        expect(json_response["confirmation_code"]).to eq("ABC123")
      end

      it "calls the CreateBookingService with correct parameters" do
        expect(Bookings::CreateBookingService).to receive(:call).with(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: 2,
          payment_method_id: nil,
          player_names: ["John Doe", "Jane Smith"]
        )
        
        make_request
      end
    end

    context "when service returns failure" do
      before do
        allow(Bookings::CreateBookingService).to receive(:call).and_return(
          double(
            success?: false,
            errors: ["Tee time is fully booked"],
            error_messages: "Tee time is fully booked"
          )
        )
      end

      it "returns validation error" do
        make_request
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to eq("Tee time is fully booked")
        expect(json_response["code"]).to eq("validation_error")
      end
    end

    include_examples "API authentication"
  end

  describe "PATCH #cancel" do
    let(:http_method) { :patch }
    let(:action) { :cancel }
    
    let(:course) { create(:course, organization: organization) }
    let(:tee_sheet) { create(:tee_sheet, course: course) }
    let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet) }
    let(:booking) { create(:booking, tee_time: tee_time, status: :confirmed) }
    let(:params) { { id: booking.id, reason: "Change of plans" } }

    before do
      # Mock the service
      allow(Bookings::CancelBookingService).to receive(:call).and_return(
        double(
          success?: true,
          booking: double(
            id: booking.id,
            confirmation_code: booking.confirmation_code,
            status: "cancelled",
            players_count: booking.players_count,
            total: booking.total,
            total_cents: booking.total_cents,
            notes: booking.notes,
            tee_time: tee_time,
            course: course,
            user: booking.user,
            booking_players: [],
            created_at: booking.created_at,
            updated_at: Time.current
          )
        )
      )
    end

    context "with valid booking" do
      it "cancels the booking successfully" do
        make_request
        
        expect(response).to have_http_status(:ok)
        expect(json_response["status"]).to eq("cancelled")
      end

      it "calls the CancelBookingService" do
        expect(Bookings::CancelBookingService).to receive(:call).with(
          booking: booking,
          reason: "Change of plans"
        )
        
        make_request
      end
    end

    include_examples "API authentication"
  end
end