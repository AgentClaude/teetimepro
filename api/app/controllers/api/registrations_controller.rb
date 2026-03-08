module Api
  class RegistrationsController < ApplicationController
    skip_before_action :set_current_organization, only: [:create]

    def create
      result = Auth::RegisterUserService.call(
        email: params[:email],
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        first_name: params[:first_name],
        last_name: params[:last_name],
        organization_name: params[:organization_name],
        organization_id: params[:organization_id]
      )

      if result.success?
        render json: {
          access_token: result.data[:access_token],
          refresh_token: result.data[:refresh_token],
          token_type: result.data[:token_type],
          expires_in: result.data[:expires_in],
          user: result.data[:user]
        }, status: :created
      else
        render json: { errors: result.errors }, status: :unprocessable_entity
      end
    end
  end
end
