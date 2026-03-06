module AuthHelper
  def sign_in_user(user = nil)
    user ||= create(:user)
    secret = ENV.fetch("JWT_SECRET_KEY", "test-secret")
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
    { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" }
  end

  def graphql_context(user: nil, organization: nil)
    user ||= create(:user)
    {
      current_user: user,
      current_organization: organization || user.organization
    }
  end
end
