module Api
  class PasswordResetsController < ApplicationController
    skip_before_action :set_current_organization, only: [:create, :update]

    # POST /api/auth/password/reset - Request reset email
    def create
      result = Auth::RequestPasswordResetService.call(email: params[:email])

      if result.success?
        render json: { message: result.data[:message] }
      else
        render json: { errors: result.errors }, status: :unprocessable_entity
      end
    end

    # PUT /api/auth/password/reset - Reset with token
    def update
      result = Auth::ResetPasswordService.call(
        token: params[:token],
        password: params[:password],
        password_confirmation: params[:password_confirmation]
      )

      if result.success?
        render json: { message: result.data[:message] }
      else
        render json: { errors: result.errors }, status: :unprocessable_entity
      end
    end
  end
end
