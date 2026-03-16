require "rails_helper"

RSpec.describe NotificationPreferences::UpdateService do
  let(:user) { create(:user) }

  describe ".call" do
    context "with valid parameters" do
      it "creates new notification preferences for user without existing preferences" do
        expect(user.notification_preference).to be_nil

        result = described_class.call(
          user: user,
          preferences: {
            email_booking_confirmation: false,
            sms_booking_reminder: false,
            reminder_hours_before: 12
          }
        )

        expect(result).to be_success
        expect(result.notification_preference).to be_persisted
        expect(result.notification_preference.user).to eq(user)
        expect(result.notification_preference.email_booking_confirmation).to be false
        expect(result.notification_preference.sms_booking_reminder).to be false
        expect(result.notification_preference.reminder_hours_before).to eq(12)

        # Verify user association is updated
        expect(user.reload.notification_preference).to eq(result.notification_preference)
      end

      it "updates existing notification preferences" do
        existing_preference = create(:notification_preference, 
          user: user,
          email_booking_confirmation: true,
          reminder_hours_before: 24
        )

        result = described_class.call(
          user: user,
          preferences: {
            email_booking_confirmation: false,
            push_marketing: true,
            reminder_hours_before: 1
          }
        )

        expect(result).to be_success
        expect(result.notification_preference).to eq(existing_preference)
        
        existing_preference.reload
        expect(existing_preference.email_booking_confirmation).to be false
        expect(existing_preference.push_marketing).to be true
        expect(existing_preference.reminder_hours_before).to eq(1)
      end

      it "handles empty preferences hash" do
        result = described_class.call(
          user: user,
          preferences: {}
        )

        expect(result).to be_success
        expect(result.notification_preference).to be_persisted
      end

      it "filters out nil values" do
        result = described_class.call(
          user: user,
          preferences: {
            email_booking_confirmation: false,
            sms_booking_reminder: nil,
            push_marketing: true
          }
        )

        expect(result).to be_success
        preference = result.notification_preference
        expect(preference.email_booking_confirmation).to be false
        expect(preference.push_marketing).to be true
        # sms_booking_reminder should use default or existing value, not nil
        expect(preference.sms_booking_reminder).not_to be_nil
      end
    end

    context "with invalid parameters" do
      it "fails when user is missing" do
        result = described_class.call(
          user: nil,
          preferences: { email_booking_confirmation: false }
        )

        expect(result).to be_failure
        expect(result.errors).to include("User can't be blank")
      end

      it "fails when reminder_hours_before is invalid" do
        result = described_class.call(
          user: user,
          preferences: { reminder_hours_before: 999 }
        )

        expect(result).to be_failure
        expect(result.errors).to include(/Reminder hours before is not included in the list/)
      end

      it "fails validation and returns errors" do
        # Mock validation failure
        preference = build(:notification_preference, user: user)
        allow(preference).to receive(:save).and_return(false)
        allow(preference).to receive_message_chain(:errors, :full_messages).and_return(["Some validation error"])
        allow(NotificationPreference).to receive(:find_or_initialize_by).and_return(preference)

        result = described_class.call(
          user: user,
          preferences: { email_booking_confirmation: false }
        )

        expect(result).to be_failure
        expect(result.errors).to include("Some validation error")
      end
    end

    context "service interface" do
      it "responds to .call method" do
        expect(described_class).to respond_to(:call)
      end

      it "returns ServiceResult object" do
        result = described_class.call(user: user, preferences: {})
        expect(result).to be_a(ServiceResult)
      end

      it "provides success? and failure? methods" do
        result = described_class.call(user: user, preferences: {})
        expect(result).to respond_to(:success?)
        expect(result).to respond_to(:failure?)
      end
    end
  end
end