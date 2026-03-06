module Users
  class FindOrCreateApiUserService < ApplicationService
    attr_accessor :organization, :email, :first_name, :last_name, :phone

    validates :organization, presence: true
    validates :email, presence: true

    def call
      return failure(errors.full_messages) unless valid?

      user = User.find_by(email: email, organization: organization)

      unless user
        user = User.new(
          email: email,
          first_name: first_name,
          last_name: last_name,
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
  end
end
