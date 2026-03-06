module GraphQLHelper
  def execute_query(query, variables: {}, context: {})
    TeeTimeProSchema.execute(query, variables: variables, context: context)
  end

  def graphql_response(result)
    JSON.parse(result.to_json)
  end

  def graphql_errors(result)
    result["errors"]&.map { |e| e["message"] } || []
  end
end
