module Api
  class SessionsController < ApplicationController
    skip_before_action :set_current_organization, only: [:create]

    def create
      user = User.find_by(email: params[:email])

      if user&.valid_password?(params[:password])
        secret = ENV.fetch("JWT_SECRET_KEY", Rails.application.secret_key_base)
        token = JWT.encode(
          {
            sub: user.id,
            email: user.email,
            role: user.role,
            organization_id: user.organization_id,
            exp: 24.hours.from_now.to_i
          },
          secret
        )

        render json: {
          token: token,
          user: {
            id: user.id,
            email: user.email,
            first_name: user.first_name,
            last_name: user.last_name,
            role: user.role,
            organization_id: user.organization_id
          }
        }
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end

    def destroy
      # With JWT, logout is handled client-side by discarding the token
      # Optionally add token to denylist here
      render json: { message: "Logged out successfully" }
    end
  end
end
