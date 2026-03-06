module Api
  class SessionsController < ApplicationController
    skip_before_action :set_current_organization, only: [:create, :refresh]

    ACCESS_TOKEN_EXPIRY = 1.hour
    REFRESH_TOKEN_EXPIRY = 7.days

    def create
      user = User.find_by(email: params[:email])

      if user&.valid_password?(params[:password])
        tokens = generate_tokens(user)

        render json: {
          access_token: tokens[:access_token],
          refresh_token: tokens[:refresh_token],
          token_type: "Bearer",
          expires_in: ACCESS_TOKEN_EXPIRY.to_i,
          user: user_payload(user)
        }
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end

    def refresh
      refresh_token = params[:refresh_token]
      return render json: { error: "Refresh token required" }, status: :bad_request unless refresh_token

      begin
        secret = jwt_secret
        payload = JWT.decode(refresh_token, secret, true, { algorithm: "HS256" }).first

        unless payload["token_type"] == "refresh"
          return render json: { error: "Invalid token type" }, status: :unauthorized
        end

        # Check if the refresh token has been revoked
        if JwtDenylist.exists?(jti: payload["jti"])
          return render json: { error: "Token has been revoked" }, status: :unauthorized
        end

        user = User.find_by(id: payload["sub"])
        return render json: { error: "User not found" }, status: :unauthorized unless user

        # Revoke the old refresh token (rotate)
        JwtDenylist.create!(jti: payload["jti"], exp: Time.at(payload["exp"]))

        # Issue new token pair
        tokens = generate_tokens(user)

        render json: {
          access_token: tokens[:access_token],
          refresh_token: tokens[:refresh_token],
          token_type: "Bearer",
          expires_in: ACCESS_TOKEN_EXPIRY.to_i,
          user: user_payload(user)
        }
      rescue JWT::ExpiredSignature
        render json: { error: "Refresh token expired" }, status: :unauthorized
      rescue JWT::DecodeError
        render json: { error: "Invalid refresh token" }, status: :unauthorized
      end
    end

    def destroy
      token = extract_token_from_request
      if token
        begin
          secret = jwt_secret
          payload = JWT.decode(token, secret, true, { algorithm: "HS256" }).first
          JwtDenylist.create!(jti: payload["jti"], exp: Time.at(payload["exp"]))
        rescue JWT::DecodeError, JWT::ExpiredSignature
          # Token already invalid, that's fine
        end
      end

      render json: { message: "Logged out successfully" }
    end

    private

    def generate_tokens(user)
      secret = jwt_secret
      access_jti = SecureRandom.uuid
      refresh_jti = SecureRandom.uuid

      access_token = JWT.encode(
        {
          sub: user.id,
          email: user.email,
          role: user.role,
          organization_id: user.organization_id,
          jti: access_jti,
          token_type: "access",
          exp: ACCESS_TOKEN_EXPIRY.from_now.to_i
        },
        secret,
        "HS256"
      )

      refresh_token = JWT.encode(
        {
          sub: user.id,
          jti: refresh_jti,
          token_type: "refresh",
          exp: REFRESH_TOKEN_EXPIRY.from_now.to_i
        },
        secret,
        "HS256"
      )

      { access_token: access_token, refresh_token: refresh_token }
    end

    def user_payload(user)
      {
        id: user.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        role: user.role,
        organization_id: user.organization_id
      }
    end

    def jwt_secret
      ENV.fetch("JWT_SECRET_KEY", Rails.application.secret_key_base)
    end
  end
end
