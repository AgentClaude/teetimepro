class ApplicationController < ActionController::API
  include Pundit::Authorization

  before_action :set_current_organization

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from AuthorizationError, with: :not_authorized

  private

  def current_user
    @current_user
  end

  def authenticate_user!
    token = extract_token_from_request
    return render_unauthorized unless token

    begin
      secret = ENV.fetch("JWT_SECRET_KEY", Rails.application.secret_key_base)
      payload = JWT.decode(token, secret).first
      @current_user = User.find_by(id: payload["sub"])
      render_unauthorized unless @current_user
    rescue JWT::DecodeError, JWT::ExpiredSignature
      render_unauthorized
    end
  end

  def extract_token_from_request
    auth_header = request.headers["Authorization"]
    return unless auth_header&.start_with?("Bearer ")

    auth_header.split(" ").last
  end

  def set_current_organization
    Organization.current = current_user&.organization
  end

  def render_unauthorized
    render json: { error: "Not authorized" }, status: :unauthorized
  end

  def not_authorized
    render json: { error: "Forbidden" }, status: :forbidden
  end

  def not_found
    render json: { error: "Not found" }, status: :not_found
  end
end
