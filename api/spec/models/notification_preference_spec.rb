require 'rails_helper'

RSpec.describe NotificationPreference, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    subject { build(:notification_preference) }

    it { should validate_inclusion_of(:reminder_hours_before).in_array([1, 2, 4, 12, 24, 48]) }
  end

  describe 'constants' do
    it 'defines REMINDER_HOURS_OPTIONS' do
      expect(NotificationPreference::REMINDER_HOURS_OPTIONS).to eq([1, 2, 4, 12, 24, 48])
    end
  end

  describe '.default_preferences' do
    let(:defaults) { NotificationPreference.default_preferences }

    it 'returns default preference values' do
      expect(defaults[:email_booking_confirmation]).to be true
      expect(defaults[:email_booking_cancellation]).to be true
      expect(defaults[:email_booking_reminder]).to be true
      expect(defaults[:email_marketing]).to be false
      expect(defaults[:sms_booking_confirmation]).to be true
      expect(defaults[:sms_booking_cancellation]).to be false
      expect(defaults[:sms_booking_reminder]).to be true
      expect(defaults[:sms_marketing]).to be false
      expect(defaults[:push_booking_confirmation]).to be true
      expect(defaults[:push_booking_cancellation]).to be true
      expect(defaults[:push_booking_reminder]).to be true
      expect(defaults[:push_marketing]).to be false
      expect(defaults[:reminder_hours_before]).to eq(24)
    end

    it 'includes all expected keys' do
      expected_keys = %i[
        email_booking_confirmation email_booking_cancellation email_booking_reminder email_marketing
        sms_booking_confirmation sms_booking_cancellation sms_booking_reminder sms_marketing
        push_booking_confirmation push_booking_cancellation push_booking_reminder push_marketing
        reminder_hours_before
      ]
      expect(defaults.keys).to match_array(expected_keys)
    end
  end

  describe 'factory' do
    it 'creates a valid notification preference' do
      preference = build(:notification_preference)
      expect(preference).to be_valid
    end

    it 'creates valid preference with traits' do
      expect(build(:notification_preference, :all_disabled)).to be_valid
      expect(build(:notification_preference, :marketing_enabled)).to be_valid
      expect(build(:notification_preference, :early_reminder)).to be_valid
      expect(build(:notification_preference, :late_reminder)).to be_valid
    end
  end

  describe 'reminder_hours_before validation' do
    it 'allows valid reminder hours' do
      [1, 2, 4, 12, 24, 48].each do |hours|
        preference = build(:notification_preference, reminder_hours_before: hours)
        expect(preference).to be_valid
      end
    end

    it 'rejects invalid reminder hours' do
      [0, 3, 5, 13, 25, 50, 100].each do |hours|
        preference = build(:notification_preference, reminder_hours_before: hours)
        expect(preference).not_to be_valid
        expect(preference.errors[:reminder_hours_before]).to be_present
      end
    end
  end
end