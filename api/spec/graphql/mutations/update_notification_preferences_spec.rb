require "rails_helper"

RSpec.describe Mutations::UpdateNotificationPreferences do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }

  let(:query) do
    <<~GQL
      mutation UpdateNotificationPreferences(
        $emailBookingConfirmation: Boolean
        $emailBookingCancellation: Boolean
        $emailBookingReminder: Boolean
        $emailMarketing: Boolean
        $smsBookingConfirmation: Boolean
        $smsBookingCancellation: Boolean
        $smsBookingReminder: Boolean
        $smsMarketing: Boolean
        $pushBookingConfirmation: Boolean
        $pushBookingCancellation: Boolean
        $pushBookingReminder: Boolean
        $pushMarketing: Boolean
        $reminderHoursBefore: Int
      ) {
        updateNotificationPreferences(
          emailBookingConfirmation: $emailBookingConfirmation
          emailBookingCancellation: $emailBookingCancellation
          emailBookingReminder: $emailBookingReminder
          emailMarketing: $emailMarketing
          smsBookingConfirmation: $smsBookingConfirmation
          smsBookingCancellation: $smsBookingCancellation
          smsBookingReminder: $smsBookingReminder
          smsMarketing: $smsMarketing
          pushBookingConfirmation: $pushBookingConfirmation
          pushBookingCancellation: $pushBookingCancellation
          pushBookingReminder: $pushBookingReminder
          pushMarketing: $pushMarketing
          reminderHoursBefore: $reminderHoursBefore
        ) {
          notificationPreference {
            id
            userId
            emailBookingConfirmation
            emailBookingCancellation
            emailBookingReminder
            emailMarketing
            smsBookingConfirmation
            smsBookingCancellation
            smsBookingReminder
            smsMarketing
            pushBookingConfirmation
            pushBookingCancellation
            pushBookingReminder
            pushMarketing
            reminderHoursBefore
          }
          errors
        }
      }
    GQL
  end

  describe "with authenticated user" do
    def execute_mutation(variables = {})
      TeeTimeProSchema.execute(
        query,
        variables: variables,
        context: { current_user: user, current_organization: organization }
      )
    end

    context "when creating new preferences" do
      it "creates notification preferences with provided values" do
        expect(user.notification_preference).to be_nil

        result = execute_mutation({
          emailBookingConfirmation: false,
          smsBookingReminder: false,
          pushMarketing: true,
          reminderHoursBefore: 12
        })

        data = result["data"]["updateNotificationPreferences"]
        expect(data["errors"]).to be_empty
        
        preference = data["notificationPreference"]
        expect(preference["emailBookingConfirmation"]).to be false
        expect(preference["smsBookingReminder"]).to be false
        expect(preference["pushMarketing"]).to be true
        expect(preference["reminderHoursBefore"]).to eq(12)
        expect(preference["userId"]).to eq(user.id.to_s)

        # Verify in database
        user.reload
        expect(user.notification_preference).to be_present
        expect(user.notification_preference.email_booking_confirmation).to be false
        expect(user.notification_preference.sms_booking_reminder).to be false
        expect(user.notification_preference.push_marketing).to be true
        expect(user.notification_preference.reminder_hours_before).to eq(12)
      end

      it "creates preferences with partial data" do
        result = execute_mutation({
          emailMarketing: true
        })

        data = result["data"]["updateNotificationPreferences"]
        expect(data["errors"]).to be_empty
        
        preference = data["notificationPreference"]
        expect(preference["emailMarketing"]).to be true
        # Other fields should use defaults
        expect(preference["emailBookingConfirmation"]).to be true
        expect(preference["reminderHoursBefore"]).to eq(24)
      end
    end

    context "when updating existing preferences" do
      let!(:existing_preference) do
        create(:notification_preference,
          user: user,
          email_booking_confirmation: true,
          sms_marketing: false,
          reminder_hours_before: 24
        )
      end

      it "updates existing preferences" do
        result = execute_mutation({
          emailBookingConfirmation: false,
          smsMarketing: true,
          reminderHoursBefore: 1
        })

        data = result["data"]["updateNotificationPreferences"]
        expect(data["errors"]).to be_empty
        
        preference = data["notificationPreference"]
        expect(preference["id"]).to eq(existing_preference.id.to_s)
        expect(preference["emailBookingConfirmation"]).to be false
        expect(preference["smsMarketing"]).to be true
        expect(preference["reminderHoursBefore"]).to eq(1)

        # Verify in database
        existing_preference.reload
        expect(existing_preference.email_booking_confirmation).to be false
        expect(existing_preference.sms_marketing).to be true
        expect(existing_preference.reminder_hours_before).to eq(1)
      end
    end

    context "with invalid data" do
      it "returns errors for invalid reminder hours" do
        result = execute_mutation({
          reminderHoursBefore: 999
        })

        data = result["data"]["updateNotificationPreferences"]
        expect(data["notificationPreference"]).to be_nil
        expect(data["errors"]).to include(/Reminder hours before is not included in the list/)
      end
    end

    context "with no variables" do
      it "succeeds with empty update" do
        result = execute_mutation({})

        data = result["data"]["updateNotificationPreferences"]
        expect(data["errors"]).to be_empty
        expect(data["notificationPreference"]).to be_present
      end
    end
  end

  describe "without authentication" do
    def execute_mutation_unauthenticated(variables = {})
      TeeTimeProSchema.execute(
        query,
        variables: variables,
        context: {}
      )
    end

    it "returns authentication error" do
      result = execute_mutation_unauthenticated({
        emailMarketing: true
      })

      expect(result["errors"]).to be_present
      expect(result["errors"].first["message"]).to eq("Not authenticated")
    end
  end
end