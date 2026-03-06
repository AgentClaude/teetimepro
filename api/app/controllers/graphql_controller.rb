class GraphqlController < ApplicationController
  before_action :authenticate_user_from_token

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      current_user: current_user,
      current_organization: current_user&.organization,
      request: request
    }

    result = TeeTimeProSchema.execute(
      query,
      variables: variables,
      context: context,
      operation_name: operation_name
    )

    render json: result
  rescue StandardError => e
    raise e unless Rails.env.production?

    render json: { errors: [{ message: "Internal server error" }] }, status: 500
  end

  private

  def authenticate_user_from_token
    token = extract_token_from_request
    return unless token

    begin
      secret = ENV.fetch("JWT_SECRET_KEY", Rails.application.secret_key_base)
      payload = JWT.decode(token, secret).first
      @current_user = User.find_by(id: payload["sub"])
    rescue JWT::DecodeError, JWT::ExpiredSignature
      @current_user = nil
    end
  end

  def prepare_variables(variables_param)
    case variables_param
    when String
      variables_param.present? ? JSON.parse(variables_param) : {}
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end
end
