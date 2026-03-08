require "rails_helper"

RSpec.describe Auth::RegisterUserService do
  let(:organization) { create(:organization) }

  describe ".call" do
    context "with valid params" do
      let(:params) do
        {
          email: "new@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "Jane",
          last_name: "Doe",
          organization_id: organization.id
        }
      end

      it "creates a user and returns tokens" do
        result = described_class.call(**params)

        expect(result).to be_success
        expect(result.data[:user][:email]).to eq("new@example.com")
        expect(result.data[:access_token]).to be_present
        expect(result.data[:refresh_token]).to be_present
        expect(result.data[:token_type]).to eq("Bearer")
      end

      it "creates the user in the database" do
        expect { described_class.call(**params) }.to change(User, :count).by(1)

        user = User.last
        expect(user.email).to eq("new@example.com")
        expect(user.first_name).to eq("Jane")
        expect(user.last_name).to eq("Doe")
        expect(user.role).to eq("golfer")
        expect(user.organization).to eq(organization)
      end
    end

    context "with new organization name" do
      let(:params) do
        {
          email: "owner@newcourse.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "Bob",
          last_name: "Builder",
          organization_name: "Pine Valley GC"
        }
      end

      it "creates a new organization" do
        expect { described_class.call(**params) }
          .to change(Organization, :count).by(1)

        expect(Organization.last.name).to eq("Pine Valley GC")
      end
    end

    context "with duplicate email" do
      before { create(:user, email: "taken@example.com") }

      it "returns failure" do
        result = described_class.call(
          email: "taken@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "John",
          last_name: "Doe"
        )

        expect(result).not_to be_success
        expect(result.errors).to include(/email/i)
      end
    end

    context "with password mismatch" do
      it "returns failure" do
        result = described_class.call(
          email: "test@example.com",
          password: "password123",
          password_confirmation: "different",
          first_name: "John",
          last_name: "Doe"
        )

        expect(result).not_to be_success
      end
    end

    context "with missing required fields" do
      it "returns failure for missing email" do
        result = described_class.call(
          email: "",
          password: "password123",
          password_confirmation: "password123",
          first_name: "John",
          last_name: "Doe"
        )

        expect(result).not_to be_success
      end
    end
  end
end
