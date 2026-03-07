require "rails_helper"

RSpec.describe Calendars::SyncBookingService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:course) { create(:course, organization: organization, name: "Pebble Beach Golf Links") }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.tomorrow) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: DateTime.tomorrow.beginning_of_day + 14.hours) }
  let(:booking) { create(:booking, tee_time: tee_time, user: user, players_count: 2, confirmation_code: "ABC123") }

  describe ".call" do
    context "with no calendar connections" do
      it "returns success with message about no connections" do
        result = described_class.call(
          booking: booking,
          action: "create"
        )

        expect(result).to be_success
        expect(result.message).to include("No calendar connections enabled")
      end
    end

    context "with Google Calendar connection" do
      let!(:google_connection) do
        create(
          :calendar_connection,
          user: user,
          provider: "google",
          enabled: true,
          calendar_id: "primary",
          access_token: "valid_token",
          token_expires_at: 1.hour.from_now
        )
      end

      before do
        allow_any_instance_of(Google::Apis::CalendarV3::CalendarService)
          .to receive(:insert_event)
          .and_return(OpenStruct.new(id: "event_123"))

        allow_any_instance_of(Google::Apis::CalendarV3::CalendarService)
          .to receive(:update_event)
          .and_return(OpenStruct.new(id: "event_123"))

        allow_any_instance_of(Google::Apis::CalendarV3::CalendarService)
          .to receive(:delete_event)
          .and_return(nil)
      end

      context "creating calendar event" do
        it "creates Google Calendar event successfully" do
          result = described_class.call(
            booking: booking,
            action: "create"
          )

          expect(result).to be_success
          expect(result.sync_results).to be_present
          expect(result.sync_results.first[:provider]).to eq("google")
          expect(result.sync_results.first[:result]).to be_success

          booking.reload
          expect(booking.calendar_event_id).to eq("event_123")
        end
      end

      context "updating calendar event" do
        before do
          booking.update!(calendar_event_id: "existing_event_123")
        end

        it "updates existing Google Calendar event" do
          result = described_class.call(
            booking: booking,
            action: "update"
          )

          expect(result).to be_success
          expect(result.sync_results.first[:result]).to be_success
        end
      end

      context "deleting calendar event" do
        before do
          booking.update!(calendar_event_id: "existing_event_123")
        end

        it "deletes Google Calendar event" do
          result = described_class.call(
            booking: booking,
            action: "delete"
          )

          expect(result).to be_success
          
          booking.reload
          expect(booking.calendar_event_id).to be_nil
        end

        it "succeeds even without stored event ID" do
          booking.update!(calendar_event_id: nil)

          result = described_class.call(
            booking: booking,
            action: "delete"
          )

          expect(result).to be_success
        end
      end

      context "with expired token requiring refresh" do
        let!(:expired_connection) do
          create(
            :calendar_connection,
            user: user,
            provider: "google",
            enabled: true,
            calendar_id: "primary",
            access_token: "expired_token",
            refresh_token: "refresh_token",
            token_expires_at: 1.hour.ago
          )
        end

        before do
          # Mock successful token refresh
          allow(Calendars::RefreshTokenService).to receive(:call)
            .and_return(OpenStruct.new(success?: true))
        end

        it "refreshes token before syncing" do
          described_class.call(
            booking: booking,
            action: "create"
          )

          expect(Calendars::RefreshTokenService).to have_received(:call)
            .with(connection: expired_connection)
        end
      end

      context "with Google API error" do
        before do
          allow_any_instance_of(Google::Apis::CalendarV3::CalendarService)
            .to receive(:insert_event)
            .and_raise(Google::Apis::Error.new("API Error"))
        end

        it "logs error but doesn't fail overall operation" do
          result = described_class.call(
            booking: booking,
            action: "create"
          )

          expect(result).to be_success
          expect(result.sync_results.first[:result]).to be_failure
          expect(result.message).to include("Some calendar syncs failed")
        end
      end

      context "with disabled connection" do
        before do
          google_connection.update!(enabled: false)
        end

        it "skips disabled connections" do
          result = described_class.call(
            booking: booking,
            action: "create"
          )

          expect(result).to be_success
          expect(result.message).to include("No calendar connections enabled")
        end
      end
    end

    context "with Apple Calendar connection (coming soon)" do
      let!(:apple_connection) do
        create(
          :calendar_connection,
          user: user,
          provider: "apple",
          enabled: true
        )
      end

      it "returns success message for Apple Calendar" do
        result = described_class.call(
          booking: booking,
          action: "create"
        )

        expect(result).to be_success
        expect(result.sync_results.first[:result]).to be_success
        expect(result.sync_results.first[:result].message).to include("Apple calendar sync not implemented")
      end
    end

    context "with multiple calendar connections" do
      let!(:google_connection) do
        create(
          :calendar_connection,
          user: user,
          provider: "google",
          enabled: true,
          calendar_id: "primary",
          access_token: "valid_token",
          token_expires_at: 1.hour.from_now
        )
      end

      let!(:apple_connection) do
        create(
          :calendar_connection,
          user: user,
          provider: "apple",
          enabled: true
        )
      end

      before do
        allow_any_instance_of(Google::Apis::CalendarV3::CalendarService)
          .to receive(:insert_event)
          .and_return(OpenStruct.new(id: "event_123"))
      end

      it "syncs with all enabled connections" do
        result = described_class.call(
          booking: booking,
          action: "create"
        )

        expect(result).to be_success
        expect(result.sync_results).to have_attributes(length: 2)
        expect(result.sync_results.map { |r| r[:provider] }).to contain_exactly("google", "apple")
      end
    end

    context "with invalid parameters" do
      it "fails without booking" do
        result = described_class.call(
          booking: nil,
          action: "create"
        )

        expect(result).to be_failure
        expect(result.errors).to include("Booking can't be blank")
      end

      it "fails with invalid action" do
        result = described_class.call(
          booking: booking,
          action: "invalid_action"
        )

        expect(result).to be_failure
        expect(result.errors).to include("Action is not included in the list")
      end
    end
  end
end