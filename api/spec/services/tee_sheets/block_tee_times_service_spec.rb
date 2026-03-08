# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeeSheets::BlockTeeTimesService, type: :service do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:user) { create(:user, organization: organization, role: :manager) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: 1.day.from_now) }

  let(:starts_at) { 1.day.from_now.beginning_of_day + 8.hours }
  let(:ends_at) { 1.day.from_now.beginning_of_day + 12.hours }

  let(:params) do
    {
      organization: organization,
      course: course,
      user: user,
      block_type: "maintenance",
      reason: "Greens aeration",
      description: "Scheduled maintenance",
      starts_at: starts_at,
      ends_at: ends_at
    }
  end

  describe "#call" do
    context "with available tee times in range" do
      let!(:tee_time_1) { create(:tee_time, tee_sheet: tee_sheet, starts_at: starts_at + 30.minutes, status: :available) }
      let!(:tee_time_2) { create(:tee_time, tee_sheet: tee_sheet, starts_at: starts_at + 1.hour, status: :available) }
      let!(:tee_time_outside) { create(:tee_time, tee_sheet: tee_sheet, starts_at: ends_at + 1.hour, status: :available) }

      it "creates a tee time block" do
        result = described_class.call(**params)
        expect(result).to be_success
        expect(result.data.block).to be_a(TeeTimeBlock)
        expect(result.data.block.reason).to eq("Greens aeration")
        expect(result.data.block).to be_maintenance
      end

      it "blocks tee times in the range" do
        result = described_class.call(**params)
        expect(result.data.affected_count).to eq(2)

        tee_time_1.reload
        expect(tee_time_1.status).to eq("maintenance")
        expect(tee_time_1.tee_time_block_id).to eq(result.data.block.id)
        expect(tee_time_1.previous_status).to eq(TeeTime.statuses[:available])
      end

      it "does not block tee times outside the range" do
        described_class.call(**params)
        tee_time_outside.reload
        expect(tee_time_outside.status).to eq("available")
      end

      it "records affected count on the block" do
        result = described_class.call(**params)
        expect(result.data.block.affected_tee_time_count).to eq(2)
      end
    end

    context "with booked tee times" do
      let!(:booked_tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: starts_at + 30.minutes, status: :partially_booked) }
      let!(:booking) { create(:booking, tee_time: booked_tee_time, status: :confirmed) }

      it "skips tee times with active bookings" do
        result = described_class.call(**params)
        expect(result).to be_success
        expect(result.data.affected_count).to eq(0)
        booked_tee_time.reload
        expect(booked_tee_time.status).to eq("partially_booked")
      end
    end

    context "with event block type" do
      it "sets status to blocked instead of maintenance" do
        params[:block_type] = "event"
        tee_time = create(:tee_time, tee_sheet: tee_sheet, starts_at: starts_at + 30.minutes, status: :available)

        result = described_class.call(**params)
        expect(result).to be_success

        tee_time.reload
        expect(tee_time.status).to eq("blocked")
      end
    end

    context "with invalid params" do
      it "fails when reason is missing" do
        params[:reason] = nil
        result = described_class.call(**params)
        expect(result).not_to be_success
      end

      it "fails when ends_at is before starts_at" do
        params[:ends_at] = params[:starts_at] - 1.hour
        result = described_class.call(**params)
        expect(result).not_to be_success
        expect(result.errors).to include("End time must be after start time")
      end

      it "fails when course belongs to different organization" do
        other_org = create(:organization)
        other_course = create(:course, organization: other_org)
        params[:course] = other_course
        result = described_class.call(**params)
        expect(result).not_to be_success
      end
    end
  end
end
