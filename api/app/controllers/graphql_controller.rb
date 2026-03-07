class GraphqlController < ApplicationController
  before_action :authenticate_user_from_token
  before_action :set_paper_trail_whodunnit

  skip_before_action :authenticate_user_from_token, only: [:playground]
  skip_before_action :set_paper_trail_whodunnit, only: [:playground]

  def playground
    render html: <<~HTML.html_safe
      <!DOCTYPE html>
      <html>
      <head>
        <title>TeeTimes Pro — GraphQL Playground</title>
        <link rel="stylesheet" href="https://unpkg.com/graphiql@3/graphiql.min.css" />
      </head>
      <body style="margin:0;height:100vh;">
        <div id="graphiql" style="height:100vh;"></div>
        <script crossorigin src="https://unpkg.com/react@18/umd/react.production.min.js"></script>
        <script crossorigin src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"></script>
        <script crossorigin src="https://unpkg.com/graphiql@3/graphiql.min.js"></script>
        <script>
          const fetcher = GraphiQL.createFetcher({ url: '/graphql' });
          ReactDOM.createRoot(document.getElementById('graphiql')).render(
            React.createElement(GraphiQL, {
              fetcher,
              defaultEditorToolsVisibility: true,
            })
          );
        </script>
      </body>
      </html>
    HTML
  end

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
