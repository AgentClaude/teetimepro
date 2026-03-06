class Rack::Attack
  # Use Redis as the cache store for rate limiting
  self.cache.store = Rails.cache

  # Extract API key from request for rate limiting
  def self.extract_api_key(request)
    auth_header = request.env['HTTP_AUTHORIZATION']
    return nil unless auth_header&.start_with?('Bearer tp_')

    auth_header.split(' ').last
  end

  # Extract rate limit tier from API key
  def self.rate_limit_tier_for_key(api_key)
    return 'standard' unless api_key

    # Quick lookup without full authentication for rate limiting
    digest = Digest::SHA256.hexdigest(api_key)
    cached_tier = Rails.cache.fetch("api_key_tier:#{digest}", expires_in: 5.minutes) do
      key_record = ::ApiKey.active.find_by(key_digest: digest)
      key_record&.rate_limit_tier || 'standard'
    end

    cached_tier
  end

  # Rate limit by API key with tier-based limits
  throttle('api/v1/by_api_key', limit: proc { |req| 
    api_key = extract_api_key(req)
    tier = rate_limit_tier_for_key(api_key)
    
    case tier
    when 'premium'
      300 # 300 requests per minute
    when 'enterprise'
      1000 # 1000 requests per minute
    else
      60 # standard: 60 requests per minute
    end
  }, period: 1.minute) do |req|
    if req.path.start_with?('/api/v1/')
      api_key = extract_api_key(req)
      api_key ? Digest::SHA256.hexdigest(api_key)[0..15] : req.ip
    end
  end

  # Fallback rate limit for requests without API keys
  throttle('api/v1/by_ip', limit: 30, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/api/v1/') && !extract_api_key(req)
  end

  # Aggressive rate limiting for potential abuse
  throttle('api/abuse', limit: 5, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/api/') && req.user_agent.blank?
  end

  # Custom response for rate limited requests
  self.throttled_responder = lambda do |env|
    match_data = env['rack.attack.match_data'] || {}
    now = Time.now.to_i
    retry_after = (match_data[:period] || 60) - (now - (match_data[:epoch] || now))
    retry_after = [retry_after, 1].max

    headers = {
      'Content-Type' => 'application/json',
      'X-RateLimit-Limit' => (match_data[:limit] || 60).to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset' => (now + retry_after).to_s,
      'Retry-After' => retry_after.to_s
    }

    body = {
      error: {
        code: 'rate_limit_exceeded',
        message: 'Too many requests. Please slow down.',
        retry_after: retry_after
      }
    }

    [429, headers, [body.to_json]]
  end
end

# Enable rack-attack
Rails.application.config.middleware.use Rack::Attack