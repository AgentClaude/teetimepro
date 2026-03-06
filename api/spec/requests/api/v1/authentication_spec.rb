require 'rails_helper'

RSpec.describe 'API Authentication', type: :request do
  let(:organization) { create(:organization) }
  let!(:course) { create(:course, organization: organization) }
  let!(:api_key) { create(:api_key, organization: organization) }

  describe 'API Key Authentication' do
    context 'with valid API key' do
      let(:headers) do
        { 'Authorization' => "Bearer #{api_key.display_key}" }
      end

      it 'allows access to protected endpoints' do
        get '/api/v1/courses', headers: headers

        expect(response).to have_http_status(:ok)
      end

      it 'updates last_used_at timestamp' do
        expect {
          get '/api/v1/courses', headers: headers
        }.to change { api_key.reload.last_used_at }
      end
    end

    context 'with missing API key' do
      it 'returns unauthorized' do
        get '/api/v1/courses'

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']['code']).to eq('unauthorized')
        expect(json_response['error']['message']).to eq('API key required')
      end
    end

    context 'with invalid API key format' do
      it 'returns unauthorized for non-Bearer token' do
        get '/api/v1/courses', headers: { 'Authorization' => 'Basic invalid' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']['code']).to eq('unauthorized')
        expect(json_response['error']['message']).to eq('API key required')
      end

      it 'returns unauthorized for invalid tp_ key' do
        get '/api/v1/courses', headers: { 'Authorization' => 'Bearer invalid_key' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']['code']).to eq('unauthorized')
        expect(json_response['error']['message']).to eq('Invalid API key format')
      end
    end

    context 'with inactive API key' do
      let!(:inactive_key) { create(:api_key, :inactive, organization: organization) }
      let(:headers) do
        { 'Authorization' => "Bearer #{inactive_key.display_key}" }
      end

      it 'returns unauthorized' do
        get '/api/v1/courses', headers: headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']['code']).to eq('unauthorized')
        expect(json_response['error']['message']).to eq('Invalid or inactive API key')
      end
    end

    context 'with expired API key' do
      let!(:expired_key) { create(:api_key, :expired, organization: organization) }
      let(:headers) do
        { 'Authorization' => "Bearer #{expired_key.display_key}" }
      end

      it 'returns unauthorized' do
        get '/api/v1/courses', headers: headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']['code']).to eq('unauthorized')
        expect(json_response['error']['message']).to eq('Invalid or inactive API key')
      end
    end

    context 'with non-existent API key' do
      let(:headers) do
        { 'Authorization' => 'Bearer tp_nonexistent_key_that_is_long_enough' }
      end

      it 'returns unauthorized' do
        get '/api/v1/courses', headers: headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']['code']).to eq('unauthorized')
        expect(json_response['error']['message']).to eq('Invalid or inactive API key')
      end
    end
  end

  describe 'Organization Scoping' do
    let(:other_organization) { create(:organization) }
    let!(:other_course) { create(:course, organization: other_organization) }
    let(:headers) do
      { 'Authorization' => "Bearer #{api_key.display_key}" }
    end

    it 'only returns resources from the API key organization' do
      get '/api/v1/courses', headers: headers

      expect(response).to have_http_status(:ok)
      course_ids = json_response['data'].map { |c| c['id'] }
      expect(course_ids).to include(course.id)
      expect(course_ids).not_to include(other_course.id)
    end

    it 'returns not found for resources in other organizations' do
      get "/api/v1/courses/#{other_course.id}", headers: headers

      expect(response).to have_http_status(:not_found)
      expect(json_response['error']['code']).to eq('not_found')
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end