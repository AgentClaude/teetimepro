class Auth::RegisterUserService < ApplicationService
  attr_accessor :email, :password, :password_confirmation,
                :first_name, :last_name,
                :organization_name, :organization_id

  validates :email, presence: true
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  validate :passwords_match

  def call
    return validation_failure(self) unless valid?

    organization = resolve_organization
    return failure(["Organization not found"]) unless organization

    user = User.new(
      email: email.downcase.strip,
      password: password,
      password_confirmation: password_confirmation,
      first_name: first_name,
      last_name: last_name,
      role: :golfer,
      organization: organization
    )

    if user.save
      tokens = generate_tokens(user)
      success(
        user: user_payload(user),
        access_token: tokens[:access_token],
        refresh_token: tokens[:refresh_token],
        token_type: "Bearer",
        expires_in: 1.hour.to_i
      )
    else
      failure(user.errors.full_messages)
    end
  end

  private

  def passwords_match
    return unless password.present? && password_confirmation.present?

    errors.add(:password_confirmation, "doesn't match password") if password != password_confirmation
  end

  def resolve_organization
    if organization_id.present?
      Organization.find_by(id: organization_id)
    elsif organization_name.present?
      Organization.create(name: organization_name)
    else
      Organization.first_or_create!(name: "Default Organization")
    end
  end

  def generate_tokens(user)
    secret = ENV.fetch("JWT_SECRET_KEY", Rails.application.secret_key_base)
    access_jti = SecureRandom.uuid
    refresh_jti = SecureRandom.uuid

    access_token = JWT.encode(
      {
        sub: user.id, email: user.email, role: user.role,
        organization_id: user.organization_id,
        jti: access_jti, token_type: "access",
        exp: 1.hour.from_now.to_i
      }, secret, "HS256"
    )

    refresh_token = JWT.encode(
      {
        sub: user.id, jti: refresh_jti, token_type: "refresh",
        exp: 7.days.from_now.to_i
      }, secret, "HS256"
    )

    { access_token: access_token, refresh_token: refresh_token }
  end

  def user_payload(user)
    {
      id: user.id, email: user.email,
      first_name: user.first_name, last_name: user.last_name,
      role: user.role, organization_id: user.organization_id
    }
  end
end
