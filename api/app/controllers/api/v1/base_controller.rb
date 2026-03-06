class Api::V1::BaseController < ActionController::API
  include Pundit::Authorization

  before_action :authenticate_api_key!
  before_action :set_organization_from_api_key

  rescue_from Pundit::NotAuthorizedError, with: :forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def authenticate_api_key!
    key = extract_api_key_from_request
    return render_unauthorized('API key required') unless key

    result = ApiKeys::AuthenticateApiKeyService.call(key: key)
    
    unless result.success?
      return render_unauthorized(result.error_messages.first)
    end

    @current_api_key = result.data[:api_key]
    @current_organization = result.data[:organization]
  end

  def extract_api_key_from_request
    auth_header = request.headers['Authorization']
    return nil unless auth_header&.start_with?('Bearer tp_')

    auth_header.split(' ').last
  end

  def set_organization_from_api_key
    return unless @current_organization

    Organization.current = @current_organization
  end

  def current_organization
    @current_organization
  end

  def current_api_key
    @current_api_key
  end

  # Error response helpers
  def render_unauthorized(message = 'Unauthorized')
    render json: {
      error: {
        code: 'unauthorized',
        message: message
      }
    }, status: :unauthorized
  end

  def forbidden
    render json: {
      error: {
        code: 'forbidden',
        message: 'Access forbidden'
      }
    }, status: :forbidden
  end

  def not_found
    render json: {
      error: {
        code: 'not_found',
        message: 'Resource not found'
      }
    }, status: :not_found
  end

  # Service response helpers
  def render_service_error(result)
    render json: {
      error: {
        code: 'validation_error',
        message: result.error_messages.join(', '),
        details: result.errors
      }
    }, status: :unprocessable_entity
  end

  def render_service_success(result, status: :ok)
    render json: result.data, status: status
  end

  # Pagination helpers
  def paginate(collection, per_page: 25)
    page = params[:page]&.to_i || 1
    per_page = [params[:per_page]&.to_i || per_page, 100].min

    collection.page(page).per(per_page)
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      per_page: collection.limit_value,
      total_pages: collection.total_pages,
      total_count: collection.total_count
    }
  end

  def render_paginated(data, collection, serializer_class = nil)
    if serializer_class
      serialized_data = serializer_class.collection(data)
    else
      serialized_data = data
    end

    render json: {
      data: serialized_data,
      meta: pagination_meta(collection)
    }
  end
end