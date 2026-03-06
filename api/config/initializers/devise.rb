Devise.setup do |config|
  config.mailer_sender = ENV.fetch("FROM_EMAIL", "noreply@teetimespro.com")
  config.navigational_formats = []

  config.jwt do |jwt|
    jwt.secret = ENV.fetch("JWT_SECRET_KEY", Rails.application.secret_key_base)
    jwt.dispatch_requests = [
      ["POST", %r{^/api/auth/login$}]
    ]
    jwt.revocation_requests = [
      ["DELETE", %r{^/api/auth/logout$}]
    ]
    jwt.expiration_time = 1.hour.to_i
  end
end
