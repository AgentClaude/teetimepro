class Auth::RequestPasswordResetService < ApplicationService
  attr_accessor :email

  validates :email, presence: true

  def call
    return validation_failure(self) unless valid?

    user = User.find_by(email: email.downcase.strip)

    # Always return success to prevent email enumeration
    if user
      token = generate_reset_token(user)
      PasswordResetMailer.reset_instructions(user, token).deliver_later
    end

    success(message: "If an account exists with that email, password reset instructions have been sent.")
  end

  private

  def generate_reset_token(user)
    raw_token = SecureRandom.urlsafe_base64(32)
    hashed_token = Digest::SHA256.hexdigest(raw_token)

    user.update!(
      reset_password_token: hashed_token,
      reset_password_sent_at: Time.current
    )

    raw_token
  end
end
