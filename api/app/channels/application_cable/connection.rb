module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token]
      return reject_unauthorized_connection unless token

      secret = ENV.fetch("JWT_SECRET_KEY", Rails.application.secret_key_base)
      payload = JWT.decode(token, secret, true, { algorithm: "HS256" }).first
      user = User.find_by(id: payload["sub"])
      user || reject_unauthorized_connection
    rescue JWT::DecodeError, JWT::ExpiredSignature
      reject_unauthorized_connection
    end
  end
end
