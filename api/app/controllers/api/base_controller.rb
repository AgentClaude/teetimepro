class Api::BaseController < ActionController::API
  include Pundit::Authorization

  before_action :authenticate_api_key!
  before_action :set_organization_from_api_key

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def authenticate_api_key!
    token = extract_api_key_from_request
    return render_unauthorized("API key required") unless token

    @current_api_key = ApiKey.authenticate(token)
    return render_unauthorized("Invalid API key") unless @current_api_key
  end

  def extract_api_key_from_request
    auth_header = request.headers["Authorization"]
    return unless auth_header&.start_with?("Bearer tp_")

    auth_header.split(" ").last
  end

  def set_organization_from_api_key
    return unless @current_api_key

    @current_organization = @current_api_key.organization
    Organization.current = @current_organization
  end

  def current_organization
    @current_organization
  end

  def current_api_key
    @current_api_key
  end

  def render_unauthorized(message = "Unauthorized")
    render json: {
      error: message,
      code: "unauthorized"
    }, status: :unauthorized
  end

  def not_authorized
    render json: {
      error: "Access forbidden",
      code: "forbidden"
    }, status: :forbidden
  end

  def not_found
    render json: {
      error: "Resource not found",
      code: "not_found"
    }, status: :not_found
  end

  def render_service_error(result)
    render json: {
      error: result.error_messages,
      code: "validation_error",
      details: result.errors
    }, status: :unprocessable_entity
  end

  def render_service_success(result, status: :ok)
    if result.data.respond_to?(:each) && !result.data.is_a?(String)
      render json: { data: result.data }, status: status
    else
      render json: result.data, status: status
    end
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
end
