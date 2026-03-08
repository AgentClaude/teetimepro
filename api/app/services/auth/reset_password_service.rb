class Auth::ResetPasswordService < ApplicationService
  RESET_TOKEN_EXPIRY = 2.hours

  attr_accessor :token, :password, :password_confirmation

  validates :token, presence: true
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true

  validate :passwords_match

  def call
    return validation_failure(self) unless valid?

    hashed_token = Digest::SHA256.hexdigest(token)
    user = User.find_by(reset_password_token: hashed_token)

    return failure(["Invalid or expired reset token"]) unless user
    return failure(["Reset token has expired"]) if token_expired?(user)

    user.password = password
    user.password_confirmation = password_confirmation
    user.reset_password_token = nil
    user.reset_password_sent_at = nil

    if user.save
      # Revoke all existing JWT tokens by clearing sessions
      JwtDenylist.where("exp > ?", Time.current).destroy_all
      success(message: "Password has been reset successfully")
    else
      failure(user.errors.full_messages)
    end
  end

  private

  def passwords_match
    return unless password.present? && password_confirmation.present?

    errors.add(:password_confirmation, "doesn't match password") if password != password_confirmation
  end

  def token_expired?(user)
    user.reset_password_sent_at.nil? || user.reset_password_sent_at < RESET_TOKEN_EXPIRY.ago
  end
end
