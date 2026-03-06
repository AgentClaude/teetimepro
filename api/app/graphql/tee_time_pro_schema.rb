class TeeTimeProSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  # Limits
  max_complexity 300
  max_depth 15

  # Error handling
  rescue_from(ActiveRecord::RecordNotFound) do |_err, _obj, _args, _ctx, field|
    raise GraphQL::ExecutionError, "#{field.type.unwrap.graphql_name} not found"
  end

  rescue_from(AuthorizationError) do |err, _obj, _args, _ctx, _field|
    raise GraphQL::ExecutionError, err.message
  end

  rescue_from(Pundit::NotAuthorizedError) do |_err, _obj, _args, _ctx, _field|
    raise GraphQL::ExecutionError, "Not authorized"
  end
end
