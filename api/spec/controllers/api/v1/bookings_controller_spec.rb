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

  # Build a booking-like double that satisfies booking_data helper
  def build_booking_mock(attrs = {})
    total_double = double("Money", format: "50.00")
    allow(total_double).to receive(:format).with(any_args).and_return("50.00")

    tee_time_mock = attrs[:tee_time] || tee_time
    course_mock = attrs[:course] || course

    double(
      "Booking",
      id: attrs[:id] || 123,
      confirmation_code: attrs[:confirmation_code] || "ABC123",
      status: attrs[:status] || "confirmed",
      players_count: attrs[:players_count] || 2,
      total: total_double,
      total_cents: attrs[:total_cents] || 5000,
      notes: attrs[:notes] || "",
      tee_time: tee_time_mock,
      course: course_mock,
      user: attrs[:user] || user,
      booking_players: [],
      created_at: attrs[:created_at] || Time.current,
      updated_at: attrs[:updated_at] || Time.current
    )
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
      booking_mock = build_booking_mock(tee_time: tee_time, course: course, user: user)
      data_struct = OpenStruct.new(booking: booking_mock)
      allow(Bookings::CreateBookingService).to receive(:call).and_return(
        ServiceResult.new(success: true, data: { booking: booking_mock })
      )
    end

    context "with valid parameters" do
      it "creates a booking successfully" do
        make_request

        expect(response).to have_http_status(:created)
        data = json_response["data"] || json_response
        expect(data["id"]).to eq(123)
        expect(data["confirmation_code"]).to eq("ABC123")
      end

      it "calls the CreateBookingService with correct parameters" do
        expect(Bookings::CreateBookingService).to receive(:call).with(
          hash_including(
            organization: organization,
            tee_time: tee_time,
            user: user
          )
        ).and_return(
          ServiceResult.new(success: true, data: { booking: build_booking_mock(tee_time: tee_time, course: course, user: user) })
        )

        make_request
      end
    end

    context "when service returns failure" do
      before do
        allow(Bookings::CreateBookingService).to receive(:call).and_return(
          ServiceResult.new(success: false, errors: ["Tee time is fully booked"])
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
      cancelled_mock = build_booking_mock(
        id: booking.id,
        confirmation_code: booking.confirmation_code,
        status: "cancelled",
        players_count: booking.players_count,
        total_cents: booking.total_cents,
        notes: booking.notes,
        tee_time: tee_time,
        course: course,
        user: booking.user,
        created_at: booking.created_at
      )
      allow(Bookings::CancelBookingService).to receive(:call).and_return(
        ServiceResult.new(success: true, data: { booking: cancelled_mock })
      )
    end

    context "with valid booking" do
      it "cancels the booking successfully" do
        make_request

        expect(response).to have_http_status(:ok)
        data = json_response["data"] || json_response
        expect(data["status"]).to eq("cancelled")
      end

      it "calls the CancelBookingService" do
        expect(Bookings::CancelBookingService).to receive(:call).with(
          booking: booking,
          reason: "Change of plans"
        ).and_return(
          ServiceResult.new(success: true, data: { booking: build_booking_mock(status: "cancelled", tee_time: tee_time, course: course, user: booking.user) })
        )

        make_request
      end
    end

    include_examples "API authentication"
  end
end
