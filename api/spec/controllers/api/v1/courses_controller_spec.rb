require "rails_helper"

RSpec.describe Api::V1::CoursesController, type: :controller do
  let(:organization) { create(:organization) }
  let(:api_key) { create(:api_key, organization: organization) }
  let(:headers) { { "Authorization" => "Bearer #{api_key.display_key}" } }

  def json_response
    JSON.parse(response.body)
  end

  def make_request
    request.headers.merge!(headers) if headers.present?
    get action, params: params
  end

  describe "GET #index" do
    let(:action) { :index }
    let(:params) { {} }
    
    let!(:course1) { create(:course, organization: organization) }
    let!(:course2) { create(:course, organization: organization) }
    let!(:other_org_course) { create(:course) } # Different organization

    context "with valid API key" do
      it "returns courses for the organization" do
        make_request
        
        expect(response).to have_http_status(:ok)
        expect(json_response["data"]).to be_an(Array)
        expect(json_response["data"].length).to eq(2)
        
        course_ids = json_response["data"].map { |c| c["id"] }
        expect(course_ids).to contain_exactly(course1.id, course2.id)
      end

      it "includes course details" do
        make_request
        
        course_data = json_response["data"].first
        expect(course_data).to include(
          "id",
          "name",
          "holes",
          "interval_minutes",
          "max_players_per_slot",
          "rates"
        )
      end
    end

    include_examples "API authentication"
    include_examples "API pagination"
  end

  describe "GET #show" do
    let(:action) { :show }
    let(:course) { create(:course, organization: organization) }
    let(:params) { { id: course.id } }

    context "with valid API key and course" do
      it "returns the course details" do
        make_request
        
        expect(response).to have_http_status(:ok)
        expect(json_response["data"]["id"]).to eq(course.id)
        expect(json_response["data"]["name"]).to eq(course.name)
      end
    end

    context "with course from different organization" do
      let(:other_course) { create(:course) }
      let(:params) { { id: other_course.id } }

      it "returns 404 not found" do
        make_request
        
        expect(response).to have_http_status(:not_found)
      end
    end

    include_examples "API authentication"
  end
end