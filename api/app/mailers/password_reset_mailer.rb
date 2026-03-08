class PasswordResetMailer < ApplicationMailer
  def reset_instructions(user, token)
    @user = user
    @token = token
    @reset_url = "#{frontend_url}/reset-password?token=#{token}"

    mail(
      to: user.email,
      subject: "Reset your TeeTimes Pro password"
    )
  end

  private

  def frontend_url
    ENV.fetch("FRONTEND_URL", "http://localhost:5173")
  end
end
