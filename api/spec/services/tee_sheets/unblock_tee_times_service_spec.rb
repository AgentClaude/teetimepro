# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeeSheets::UnblockTeeTimesService, type: :service do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:user) { create(:user, organization: organization, role: :manager) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: 1.day.from_now) }

  let!(:block) { create(:tee_time_block, :future, organization: organization, course: course, created_by: user) }

  describe "#call" do
    context "with blocked tee times" do
      let!(:blocked_tee_time) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: block.starts_at + 30.minutes,
          status: :blocked,
          tee_time_block: block,
          previous_status: TeeTime.statuses[:available]
        )
      end

      let!(:maintenance_tee_time) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: block.starts_at + 1.hour,
          status: :maintenance,
          tee_time_block: block,
          previous_status: TeeTime.statuses[:partially_booked]
        )
      end

      it "restores tee times to their previous status" do
        result = described_class.call(
          organization: organization,
          tee_time_block_id: block.id,
          user: user
        )

        expect(result).to be_success
        expect(result.data.restored_count).to eq(2)

        blocked_tee_time.reload
        expect(blocked_tee_time.status).to eq("available")
        expect(blocked_tee_time.tee_time_block_id).to be_nil
        expect(blocked_tee_time.previous_status).to be_nil

        maintenance_tee_time.reload
        expect(maintenance_tee_time.status).to eq("partially_booked")
      end

      it "deactivates the block" do
        described_class.call(
          organization: organization,
          tee_time_block_id: block.id,
          user: user
        )

        block.reload
        expect(block.active).to be false
      end
    end

    context "with invalid params" do
      it "fails when block is not found" do
        result = described_class.call(
          organization: organization,
          tee_time_block_id: 99999,
          user: user
        )
        expect(result).not_to be_success
        expect(result.errors).to include("Block not found")
      end

      it "fails when block belongs to different organization" do
        other_org = create(:organization)
        result = described_class.call(
          organization: other_org,
          tee_time_block_id: block.id,
          user: user
        )
        expect(result).not_to be_success
        expect(result.errors).to include("Block not found")
      end

      it "fails when block is already inactive" do
        block.update!(active: false)
        result = described_class.call(
          organization: organization,
          tee_time_block_id: block.id,
          user: user
        )
        expect(result).not_to be_success
        expect(result.errors).to include("Block is already inactive")
      end
    end
  end
end
