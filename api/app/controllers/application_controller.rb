class ApplicationController < ActionController::API
  include Pundit::Authorization
  include OrgScoped

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
      payload = JWT.decode(token, secret, true, { algorithm: "HS256" }).first

      # Only accept access tokens (not refresh tokens)
      if payload["token_type"] && payload["token_type"] != "access"
        return render_unauthorized("Invalid token type")
      end

      # Check if token has been revoked
      if payload["jti"] && JwtDenylist.exists?(jti: payload["jti"])
        return render_unauthorized("Token has been revoked")
      end

      @current_user = User.find_by(id: payload["sub"])
      render_unauthorized unless @current_user
    rescue JWT::ExpiredSignature
      render json: {
        error: "Token expired",
        code: "token_expired"
      }, status: :unauthorized
    rescue JWT::DecodeError
      render_unauthorized
    end
  end

  def extract_token_from_request
    auth_header = request.headers["Authorization"]
    return unless auth_header&.start_with?("Bearer ")

    auth_header.split(" ").last
  end

  def render_unauthorized(message = "Not authorized")
    render json: { error: message }, status: :unauthorized
  end

  def not_authorized
    render json: { error: "Forbidden" }, status: :forbidden
  end

  def not_found
    render json: { error: "Not found" }, status: :not_found
  end
end
