require "rails_helper"

RSpec.describe Api::V1::VoiceBookingsController, type: :controller do
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

  describe "POST #reserve" do
    let(:http_method) { :post }
    let(:action) { :reserve }
    
    let(:course) { create(:course, organization: organization) }
    let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.current + 1.day) }
    let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, price_cents: 5000) }
    
    let(:params) do
      {
        tee_time_id: tee_time.id,
        players_count: 2,
        caller_name: "John Doe",
        caller_phone: "+15551234567"
      }
    end

    context "with valid parameters" do
      let(:mock_service_result) do
        double(
          success?: true,
          booking_id: 123,
          confirmation_code: "ABC123DEF",
          date: "2024-03-08",
          formatted_time: "9:00 AM",
          players: 2,
          price_per_player_cents: 5000,
          total_cents: 10000,
          course_name: "Pine Valley Golf Course"
        )
      end

      before do
        allow(Voice::BookVoiceCallService).to receive(:call).and_return(mock_service_result)
      end

      it "calls the service with correct parameters" do
        expect(Voice::BookVoiceCallService).to receive(:call).with(
          organization: organization,
          tee_time_id: tee_time.id,
          players_count: 2,
          caller_name: "John Doe",
          caller_phone: "+15551234567"
        )

        make_request
      end

      it "returns created status and booking data" do
        make_request

        expect(response).to have_http_status(:created)
        expect(json_response["data"]).to include(
          "booking_id" => 123,
          "confirmation_code" => "ABC123DEF",
          "status" => "pending_voice_confirmation",
          "date" => "2024-03-08",
          "formatted_time" => "9:00 AM",
          "players" => 2,
          "price_per_player_cents" => 5000,
          "total_cents" => 10000,
          "course_name" => "Pine Valley Golf Course"
        )
      end
    end

    context "when service fails" do
      let(:mock_service_result) do
        double(
          success?: false,
          error_messages: ["Tee time not available"],
          errors: { tee_time_id: ["is invalid"] }
        )
      end

      before do
        allow(Voice::BookVoiceCallService).to receive(:call).and_return(mock_service_result)
      end

      it "returns unprocessable entity status" do
        make_request

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to include("Tee time not available")
      end
    end

    include_examples "API authentication"
  end

  describe "POST #confirm" do
    let(:http_method) { :post }
    let(:action) { :confirm }
    
    let(:params) do
      {
        booking_id: 123
      }
    end

    context "with valid parameters" do
      let(:mock_service_result) do
        double(
          success?: true,
          booking_id: 123,
          confirmation_code: "ABC123DEF",
          status: "confirmed",
          date: "2024-03-08",
          formatted_time: "9:00 AM",
          players: 2,
          total_cents: 10000,
          course_name: "Pine Valley Golf Course"
        )
      end

      before do
        allow(Voice::ConfirmVoiceBookingService).to receive(:call).and_return(mock_service_result)
      end

      it "calls the service with correct parameters" do
        expect(Voice::ConfirmVoiceBookingService).to receive(:call).with(
          organization: organization,
          booking_id: 123
        )

        make_request
      end

      it "returns ok status and confirmed booking data" do
        make_request

        expect(response).to have_http_status(:ok)
        expect(json_response["data"]).to include(
          "booking_id" => 123,
          "confirmation_code" => "ABC123DEF",
          "status" => "confirmed",
          "date" => "2024-03-08",
          "formatted_time" => "9:00 AM",
          "players" => 2,
          "total_cents" => 10000,
          "course_name" => "Pine Valley Golf Course"
        )
      end
    end

    context "when service fails" do
      let(:mock_service_result) do
        double(
          success?: false,
          error_messages: ["Booking not found or not in pending state"],
          errors: { booking_id: ["is invalid"] }
        )
      end

      before do
        allow(Voice::ConfirmVoiceBookingService).to receive(:call).and_return(mock_service_result)
      end

      it "returns unprocessable entity status" do
        make_request

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to include("Booking not found or not in pending state")
      end
    end

    include_examples "API authentication"
  end

  describe "POST #cancel" do
    let(:http_method) { :post }
    let(:action) { :cancel }
    
    let(:params) do
      {
        booking_id: 123,
        reason: "Caller changed their mind"
      }
    end

    context "with valid parameters" do
      let(:mock_service_result) do
        double(
          success?: true,
          booking_id: 123,
          confirmation_code: "ABC123DEF",
          status: "cancelled",
          cancelled_at: "2024-03-08T15:30:00Z",
          cancellation_reason: "Caller changed their mind",
          date: "2024-03-08",
          formatted_time: "9:00 AM",
          players: 2,
          course_name: "Pine Valley Golf Course"
        )
      end

      before do
        allow(Voice::CancelVoiceBookingService).to receive(:call).and_return(mock_service_result)
      end

      it "calls the service with correct parameters" do
        expect(Voice::CancelVoiceBookingService).to receive(:call).with(
          organization: organization,
          booking_id: 123,
          reason: "Caller changed their mind"
        )

        make_request
      end

      it "returns ok status and cancelled booking data" do
        make_request

        expect(response).to have_http_status(:ok)
        expect(json_response["data"]).to include(
          "booking_id" => 123,
          "confirmation_code" => "ABC123DEF",
          "status" => "cancelled",
          "cancelled_at" => "2024-03-08T15:30:00Z",
          "cancellation_reason" => "Caller changed their mind",
          "date" => "2024-03-08",
          "formatted_time" => "9:00 AM",
          "players" => 2,
          "course_name" => "Pine Valley Golf Course"
        )
      end
    end

    context "without reason parameter" do
      let(:params) do
        {
          booking_id: 123
        }
      end

      let(:mock_service_result) do
        double(
          success?: true,
          booking_id: 123,
          confirmation_code: "ABC123DEF",
          status: "cancelled",
          cancelled_at: "2024-03-08T15:30:00Z",
          cancellation_reason: "Voice booking cancelled by caller",
          date: "2024-03-08",
          formatted_time: "9:00 AM",
          players: 2,
          course_name: "Pine Valley Golf Course"
        )
      end

      before do
        allow(Voice::CancelVoiceBookingService).to receive(:call).and_return(mock_service_result)
      end

      it "calls the service with nil reason" do
        expect(Voice::CancelVoiceBookingService).to receive(:call).with(
          organization: organization,
          booking_id: 123,
          reason: nil
        )

        make_request
      end
    end

    context "when service fails" do
      let(:mock_service_result) do
        double(
          success?: false,
          error_messages: ["Booking not found or not in pending state"],
          errors: { booking_id: ["is invalid"] }
        )
      end

      before do
        allow(Voice::CancelVoiceBookingService).to receive(:call).and_return(mock_service_result)
      end

      it "returns unprocessable entity status" do
        make_request

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to include("Booking not found or not in pending state")
      end
    end

    include_examples "API authentication"
  end
end