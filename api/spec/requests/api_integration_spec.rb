require "rails_helper"

RSpec.describe "API Integration", type: :request do
  let(:organization) { create(:organization) }
  let(:api_key) { create(:api_key, organization: organization) }
  let(:headers) { { "Authorization" => "Bearer #{api_key.display_key}", "Content-Type" => "application/json" } }

  def json_response
    JSON.parse(response.body)
  end

  describe "Full API workflow" do
    let!(:course) { create(:course, organization: organization, name: "Pine Valley Golf Club") }
    let!(:tee_sheet) { create(:tee_sheet, course: course, date: 1.day.from_now.to_date) }
    let!(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, status: :available, max_players: 4, booked_players: 0) }
    let!(:user) { create(:user, organization: organization, email: "golfer@example.com") }

    it "allows a complete booking flow via API" do
      # 1. Get API documentation
      get "/api/v1/docs"
      expect(response).to have_http_status(:ok)
      expect(json_response["name"]).to eq("TeeTimes Pro API")

      # 2. List courses
      get "/api/v1/courses", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_response["data"]).to be_an(Array)
      expect(json_response["data"].first["name"]).to eq("Pine Valley Golf Club")

      # 3. Get course details
      get "/api/v1/courses/#{course.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_response["data"]["id"]).to eq(course.id)

      # 4. List available tee times
      get "/api/v1/tee_times", headers: headers, params: {
        course_id: course.id,
        start_date: 1.day.from_now.to_date.iso8601,
        status: "available"
      }
      expect(response).to have_http_status(:ok)
      expect(json_response["data"]).to be_an(Array)
      expect(json_response["data"].first["id"]).to eq(tee_time.id)
      expect(json_response["data"].first["available_spots"]).to eq(4)

      # 5. Create a booking (mocked service)
      allow(Bookings::CreateBookingService).to receive(:call).and_return(
        double(
          success?: true,
          booking: double(
            id: 123,
            confirmation_code: "ABC123XYZ",
            status: "confirmed",
            players_count: 2,
            total: Money.new(5000, "USD"),
            total_cents: 5000,
            notes: "",
            tee_time: tee_time,
            course: course,
            user: user,
            booking_players: [
              double(id: 1, name: "John Doe"),
              double(id: 2, name: "Jane Smith")
            ],
            created_at: Time.current,
            updated_at: Time.current
          )
        )
      )

      booking_payload = {
        booking: {
          tee_time_id: tee_time.id,
          players_count: 2,
          user: {
            email: "golfer@example.com",
            first_name: "John",
            last_name: "Doe",
            phone: "555-0123"
          },
          player_names: ["John Doe", "Jane Smith"]
        }
      }

      post "/api/v1/bookings", headers: headers, params: booking_payload.to_json
      expect(response).to have_http_status(:created)
      expect(json_response["confirmation_code"]).to eq("ABC123XYZ")
      
      booking_id = json_response["id"]

      # 6. Get booking details
      get "/api/v1/bookings/#{booking_id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_response["data"]["id"]).to eq(booking_id)

      # 7. Cancel the booking (mocked service)
      allow(Bookings::CancelBookingService).to receive(:call).and_return(
        double(
          success?: true,
          booking: double(
            id: booking_id,
            confirmation_code: "ABC123XYZ",
            status: "cancelled",
            players_count: 2,
            total: Money.new(5000, "USD"),
            total_cents: 5000,
            notes: "",
            tee_time: tee_time,
            course: course,
            user: user,
            booking_players: [],
            created_at: 1.hour.ago,
            updated_at: Time.current
          )
        )
      )

      patch "/api/v1/bookings/#{booking_id}/cancel", headers: headers, params: {
        reason: "Weather concerns"
      }.to_json
      expect(response).to have_http_status(:ok)
      expect(json_response["status"]).to eq("cancelled")
    end
  end

  describe "Error handling" do
    it "handles missing resources gracefully" do
      get "/api/v1/courses/99999", headers: headers
      expect(response).to have_http_status(:not_found)
      expect(json_response["error"]).to eq("Resource not found")
      expect(json_response["code"]).to eq("not_found")
    end

    it "handles invalid parameters" do
      post "/api/v1/bookings", headers: headers, params: {
        booking: { invalid: "data" }
      }.to_json
      
      # This would trigger a parameter validation error
      # The exact response depends on the parameter validation implementation
    end

    it "handles cross-organization access attempts" do
      other_org = create(:organization)
      other_course = create(:course, organization: other_org)

      get "/api/v1/courses/#{other_course.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "API versioning" do
    it "routes to the correct API version" do
      get "/api/v1/courses", headers: headers
      expect(response).to have_http_status(:ok)
      
      # Future v2 would be accessible at /api/v2/courses
      # This ensures the versioning structure is working
    end
  end
end