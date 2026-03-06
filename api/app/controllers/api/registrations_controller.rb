module Api
  class RegistrationsController < ApplicationController
    skip_before_action :set_current_organization, only: [:create]

    def create
      organization = find_or_create_organization

      user = User.new(
        email: params[:email],
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        first_name: params[:first_name],
        last_name: params[:last_name],
        role: params[:role] || :golfer,
        organization: organization
      )

      if user.save
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
        }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def find_or_create_organization
      if params[:organization_id].present?
        Organization.find(params[:organization_id])
      elsif params[:organization_name].present?
        Organization.create!(name: params[:organization_name])
      else
        Organization.first_or_create!(name: "Default Organization")
      end
    end
  end
end
