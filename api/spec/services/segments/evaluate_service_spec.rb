require "rails_helper"

RSpec.describe Segments::EvaluateService, type: :service do
  let(:org) { create(:organization) }
  let(:course) { create(:course, organization: org) }

  def create_golfer(**attrs)
    create(:user, organization: org, role: :golfer, **attrs)
  end

  def create_booking_for(user, total_cents: 10000, created_at: Time.current)
    @tee_sheet_day_offset ||= 0
    @tee_sheet_day_offset += 1
    tee_sheet = create(:tee_sheet, course: course, date: Date.current + @tee_sheet_day_offset.days)
    tee_time = create(:tee_time, tee_sheet: tee_sheet)
    create(:booking, user: user, tee_time: tee_time, total_cents: total_cents, created_at: created_at)
  end

  describe "#call" do
    it "returns all golfers with empty criteria" do
      g1 = create_golfer
      g2 = create_golfer
      create(:user, :staff, organization: org) # non-golfer

      result = described_class.call(organization: org, filter_criteria: {})
      expect(result).to be_success
      expect(result.count).to eq(2)
      expect(result.users).to include(g1, g2)
    end

    context "booking count filters" do
      it "filters by minimum booking count" do
        active = create_golfer
        inactive = create_golfer
        2.times { create_booking_for(active) }

        result = described_class.call(
          organization: org,
          filter_criteria: { "booking_count_min" => 2 }
        )

        expect(result).to be_success
        expect(result.users).to include(active)
        expect(result.users).not_to include(inactive)
      end

      it "filters by maximum booking count" do
        light = create_golfer
        heavy = create_golfer
        create_booking_for(light)
        5.times { create_booking_for(heavy) }

        result = described_class.call(
          organization: org,
          filter_criteria: { "booking_count_max" => 2 }
        )

        expect(result).to be_success
        expect(result.users).to include(light)
        expect(result.users).not_to include(heavy)
      end
    end

    context "last booking filters" do
      it "filters users who booked within N days" do
        recent = create_golfer
        old = create_golfer
        create_booking_for(recent, created_at: 5.days.ago)
        create_booking_for(old, created_at: 60.days.ago)

        result = described_class.call(
          organization: org,
          filter_criteria: { "last_booking_within_days" => 30 }
        )

        expect(result).to be_success
        expect(result.users).to include(recent)
        expect(result.users).not_to include(old)
      end

      it "filters lapsed users (no booking in N days)" do
        recent = create_golfer
        lapsed = create_golfer
        create_booking_for(recent, created_at: 5.days.ago)
        create_booking_for(lapsed, created_at: 120.days.ago)

        result = described_class.call(
          organization: org,
          filter_criteria: { "last_booking_before_days" => 90 }
        )

        expect(result).to be_success
        expect(result.users).to include(lapsed)
        expect(result.users).not_to include(recent)
      end
    end

    context "membership filters" do
      it "filters by membership status active" do
        member = create_golfer
        non_member = create_golfer
        create(:membership, organization: org, user: member, status: :active)

        result = described_class.call(
          organization: org,
          filter_criteria: { "membership_status" => "active" }
        )

        expect(result).to be_success
        expect(result.users).to include(member)
        expect(result.users).not_to include(non_member)
      end

      it "filters by membership status none" do
        member = create_golfer
        non_member = create_golfer
        create(:membership, organization: org, user: member)

        result = described_class.call(
          organization: org,
          filter_criteria: { "membership_status" => "none" }
        )

        expect(result).to be_success
        expect(result.users).to include(non_member)
        expect(result.users).not_to include(member)
      end
    end

    context "spending filters" do
      it "filters by minimum total spent" do
        big_spender = create_golfer
        small_spender = create_golfer
        create_booking_for(big_spender, total_cents: 50000)
        create_booking_for(small_spender, total_cents: 5000)

        result = described_class.call(
          organization: org,
          filter_criteria: { "total_spent_min" => 20000 }
        )

        expect(result).to be_success
        expect(result.users).to include(big_spender)
        expect(result.users).not_to include(small_spender)
      end
    end

    context "signup date filters" do
      it "filters users who signed up within N days" do
        new_user = create_golfer(created_at: 10.days.ago)
        old_user = create_golfer(created_at: 200.days.ago)

        result = described_class.call(
          organization: org,
          filter_criteria: { "signup_within_days" => 30 }
        )

        expect(result).to be_success
        expect(result.users).to include(new_user)
        expect(result.users).not_to include(old_user)
      end
    end

    context "handicap filters" do
      it "filters by handicap range" do
        low_hcp = create_golfer
        high_hcp = create_golfer
        create(:golfer_profile, user: low_hcp, handicap_index: 5.0)
        create(:golfer_profile, user: high_hcp, handicap_index: 25.0)

        result = described_class.call(
          organization: org,
          filter_criteria: { "handicap_max" => 10.0 }
        )

        expect(result).to be_success
        expect(result.users).to include(low_hcp)
        expect(result.users).not_to include(high_hcp)
      end
    end

    context "combined filters" do
      it "applies multiple criteria together" do
        target = create_golfer(created_at: 10.days.ago)
        non_target = create_golfer(created_at: 200.days.ago)
        create_booking_for(target, total_cents: 30000)
        create_booking_for(non_target, total_cents: 30000)

        result = described_class.call(
          organization: org,
          filter_criteria: {
            "signup_within_days" => 30,
            "booking_count_min" => 1
          }
        )

        expect(result).to be_success
        expect(result.users).to include(target)
        expect(result.users).not_to include(non_target)
      end
    end

    it "fails with missing organization" do
      result = described_class.call(organization: nil, filter_criteria: {})
      expect(result).to be_failure
    end
  end
end
