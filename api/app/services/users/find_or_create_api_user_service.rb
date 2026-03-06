module Users
  class FindOrCreateApiUserService < ApplicationService
    attr_accessor :organization, :email, :first_name, :last_name, :phone

    validates :organization, presence: true
    validate :email_or_phone_present

    def call
      return failure(errors.full_messages) unless valid?

      user = find_existing_user

      unless user
        generated_email = email.presence || "voice-#{phone.to_s.gsub(/\D/, '')}@#{organization.slug}.local"

        user = User.new(
          email: generated_email,
          first_name: first_name.presence || "Guest",
          last_name: last_name.presence || "Caller",
          phone: phone,
          organization: organization,
          password: SecureRandom.urlsafe_base64(16)
        )

        unless user.save
          return failure(user.errors.full_messages)
        end
      end

      success({ user: user })
    end

    private

    def email_or_phone_present
      errors.add(:base, "Email or phone is required") if email.blank? && phone.blank?
    end

    def find_existing_user
      if email.present?
        User.find_by(email: email, organization: organization)
      elsif phone.present?
        User.find_by(phone: phone, organization: organization)
      end
    end
  end
end
