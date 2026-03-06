module ApiKeys
  class CreateApiKeyService < ApplicationService
    attr_accessor :organization, :name, :scopes, :rate_limit_tier, :expires_at

    validates :organization, presence: true
    validates :name, presence: true, length: { minimum: 3, maximum: 100 }
    validates :scopes, presence: true
    validates :rate_limit_tier, inclusion: { in: %w[standard premium enterprise] }

    def call
      return failure(errors.full_messages) unless valid?

      api_key = organization.api_keys.build(
        name: name,
        scopes: normalize_scopes,
        rate_limit_tier: rate_limit_tier || 'standard',
        expires_at: expires_at
      )

      if api_key.save
        success({
          api_key: {
            id: api_key.id,
            name: api_key.name,
            key: api_key.display_key, # Raw key returned only on creation
            prefix: api_key.prefix,
            scopes: api_key.scopes,
            rate_limit_tier: api_key.rate_limit_tier,
            rate_limit: api_key.rate_limit,
            expires_at: api_key.expires_at,
            created_at: api_key.created_at
          }
        })
      else
        failure(api_key.errors.full_messages)
      end
    end

    private

    def normalize_scopes
      return ['read'] if scopes.blank?

      valid_scopes = %w[read write admin]
      Array(scopes).map(&:to_s).select { |scope| valid_scopes.include?(scope) }.uniq
    end
  end
end