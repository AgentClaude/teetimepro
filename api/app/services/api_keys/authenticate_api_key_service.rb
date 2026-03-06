module ApiKeys
  class AuthenticateApiKeyService < ApplicationService
    attr_accessor :key, :required_scope

    validates :key, presence: true

    def call
      return failure(['API key is required']) unless valid?
      return failure(['Invalid API key format']) unless valid_key_format?

      api_key = ApiKey.authenticate(key)
      return failure(['Invalid or inactive API key']) unless api_key

      # Check scope if required
      if required_scope && !api_key.has_scope?(required_scope)
        return failure(["Insufficient permissions. Required scope: #{required_scope}"])
      end

      success({
        api_key: api_key,
        organization: api_key.organization,
        rate_limit: api_key.rate_limit,
        rate_limit_tier: api_key.rate_limit_tier
      })
    end

    private

    def valid_key_format?
      key&.start_with?('tp_') && key.length > 10
    end
  end
end