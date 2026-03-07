require 'rails_helper'

RSpec.describe PricingRule, type: :model do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }

  describe 'validations' do
    subject(:pricing_rule) { build(:pricing_rule, organization: organization) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:rule_type) }
    it { is_expected.to validate_inclusion_of(:rule_type).in_array(PricingRule::RULE_TYPES) }
    it { is_expected.to validate_presence_of(:multiplier) }
    it { is_expected.to validate_numericality_of(:multiplier).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:priority) }
    it { is_expected.to validate_numericality_of(:priority).is_greater_than_or_equal_to(0) }

    describe 'date validation' do
      context 'when end_date is before start_date' do
        before do
          pricing_rule.start_date = Date.current
          pricing_rule.end_date = 1.day.ago.to_date
        end

        it 'is invalid' do
          expect(pricing_rule).not_to be_valid
          expect(pricing_rule.errors[:end_date]).to include('must be after start date')
        end
      end

      context 'when end_date is after start_date' do
        before do
          pricing_rule.start_date = Date.current
          pricing_rule.end_date = 1.day.from_now.to_date
        end

        it 'is valid' do
          expect(pricing_rule).to be_valid
        end
      end

      context 'when dates are nil' do
        before do
          pricing_rule.start_date = nil
          pricing_rule.end_date = nil
        end

        it 'is valid' do
          expect(pricing_rule).to be_valid
        end
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:course).optional }
  end

  describe 'scopes' do
    let!(:active_rule) { create(:pricing_rule, organization: organization, active: true) }
    let!(:inactive_rule) { create(:pricing_rule, organization: organization, active: false) }
    let!(:high_priority) { create(:pricing_rule, organization: organization, priority: 100) }
    let!(:low_priority) { create(:pricing_rule, organization: organization, priority: 50) }

    describe '.active' do
      it 'returns only active rules' do
        expect(PricingRule.active).to include(active_rule)
        expect(PricingRule.active).not_to include(inactive_rule)
      end
    end

    describe '.by_priority' do
      it 'orders by priority descending' do
        expect(PricingRule.by_priority.first).to eq(high_priority)
        expect(PricingRule.by_priority.last).to eq(low_priority)
      end
    end

    describe '.valid_for_date' do
      let(:current_date) { Date.current }
      let!(:current_rule) do
        create(:pricing_rule, 
               organization: organization,
               start_date: 1.day.ago.to_date,
               end_date: 1.day.from_now.to_date)
      end
      let!(:future_rule) do
        create(:pricing_rule,
               organization: organization,
               start_date: 1.day.from_now.to_date,
               end_date: 5.days.from_now.to_date)
      end
      let!(:past_rule) do
        create(:pricing_rule,
               organization: organization,
               start_date: 5.days.ago.to_date,
               end_date: 1.day.ago.to_date)
      end

      it 'returns only rules valid for the given date' do
        result = PricingRule.valid_for_date(current_date)
        expect(result).to include(current_rule)
        expect(result).not_to include(future_rule, past_rule)
      end
    end
  end

  describe '#applicable_to_tee_time?' do
    let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.current.next_occurring(:saturday)) }
    let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: tee_sheet.date.beginning_of_day + 9.hours) }

    context 'with day_of_week rule' do
      let(:weekend_rule) do
        create(:pricing_rule,
               organization: organization,
               rule_type: 'day_of_week',
               conditions: { days: ['saturday', 'sunday'] })
      end

      it 'applies to weekend tee times' do
        expect(weekend_rule.applicable_to_tee_time?(tee_time)).to be true
      end

      context 'when tee time is on a weekday' do
        let(:weekday_tee_sheet) { create(:tee_sheet, course: course, date: Date.current.next_occurring(:monday)) }
        let(:weekday_tee_time) { create(:tee_time, tee_sheet: weekday_tee_sheet) }

        it 'does not apply to weekday tee times' do
          expect(weekend_rule.applicable_to_tee_time?(weekday_tee_time)).to be false
        end
      end
    end

    context 'with time_of_day rule' do
      let(:morning_rule) do
        create(:pricing_rule,
               organization: organization,
               rule_type: 'time_of_day',
               conditions: { hours: { start: 7, end: 11 } })
      end

      it 'applies to morning tee times' do
        expect(morning_rule.applicable_to_tee_time?(tee_time)).to be true
      end

      context 'when tee time is in the afternoon' do
        before { tee_time.update!(starts_at: tee_time.starts_at.change(hour: 15)) }

        it 'does not apply to afternoon tee times' do
          expect(morning_rule.applicable_to_tee_time?(tee_time)).to be false
        end
      end
    end

    context 'with occupancy rule' do
      let(:occupancy_rule) do
        create(:pricing_rule,
               organization: organization,
               rule_type: 'occupancy',
               conditions: { threshold: 75, operator: 'greater_than' })
      end

      before do
        # Create additional tee times to simulate high occupancy
        create_list(:tee_time, 3, 
                   tee_sheet: tee_sheet, 
                   max_players: 4, 
                   booked_players: 4)
        # Current tee_time: max_players: 4, booked_players: 0
        # Total: 16 max, 12 booked = 75% occupancy
        tee_sheet.reload
      end

      it 'does not apply when occupancy is at threshold' do
        expect(occupancy_rule.applicable_to_tee_time?(tee_time)).to be false
      end

      context 'when occupancy is above threshold' do
        before do
          # Book one more player to push occupancy above 75%
          tee_time.update!(booked_players: 1) # Now 13/16 = 81.25%
        end

        it 'applies when occupancy is above threshold' do
          expect(occupancy_rule.applicable_to_tee_time?(tee_time)).to be true
        end
      end
    end

    context 'with advance_booking rule' do
      let(:advance_rule) do
        create(:pricing_rule,
               organization: organization,
               rule_type: 'advance_booking',
               conditions: { hours: 24, operator: 'greater_than' })
      end

      context 'when booking more than 24 hours in advance' do
        before { tee_time.update!(starts_at: 25.hours.from_now) }

        it 'applies to advance bookings' do
          expect(advance_rule.applicable_to_tee_time?(tee_time)).to be true
        end
      end

      context 'when booking less than 24 hours in advance' do
        before { tee_time.update!(starts_at: 12.hours.from_now) }

        it 'does not apply to short-notice bookings' do
          expect(advance_rule.applicable_to_tee_time?(tee_time)).to be false
        end
      end
    end

    context 'with last_minute rule' do
      let(:last_minute_rule) do
        create(:pricing_rule,
               organization: organization,
               rule_type: 'last_minute',
               conditions: { hours: 2 })
      end

      context 'when tee time is within 2 hours' do
        before { tee_time.update!(starts_at: 1.hour.from_now) }

        it 'applies to last-minute bookings' do
          expect(last_minute_rule.applicable_to_tee_time?(tee_time)).to be true
        end
      end

      context 'when tee time is more than 2 hours away' do
        before { tee_time.update!(starts_at: 3.hours.from_now) }

        it 'does not apply to advance bookings' do
          expect(last_minute_rule.applicable_to_tee_time?(tee_time)).to be false
        end
      end
    end

    context 'when rule is inactive' do
      let(:inactive_rule) do
        create(:pricing_rule,
               organization: organization,
               active: false,
               rule_type: 'day_of_week',
               conditions: { days: ['saturday'] })
      end

      it 'does not apply inactive rules' do
        expect(inactive_rule.applicable_to_tee_time?(tee_time)).to be false
      end
    end

    context 'when rule has date restrictions' do
      let(:future_rule) do
        create(:pricing_rule,
               organization: organization,
               start_date: 1.day.from_now.to_date,
               end_date: 5.days.from_now.to_date,
               rule_type: 'day_of_week',
               conditions: { days: ['saturday'] })
      end

      it 'does not apply rules outside date range' do
        expect(future_rule.applicable_to_tee_time?(tee_time)).to be false
      end
    end

    context 'when rule is course-specific' do
      let(:other_course) { create(:course, organization: organization) }
      let(:course_specific_rule) do
        create(:pricing_rule,
               organization: organization,
               course: other_course,
               rule_type: 'day_of_week',
               conditions: { days: ['saturday'] })
      end

      it 'does not apply to other courses' do
        expect(course_specific_rule.applicable_to_tee_time?(tee_time)).to be false
      end
    end
  end

  describe 'monetization' do
    let(:pricing_rule) { create(:pricing_rule, flat_adjustment_cents: 500) }

    it 'monetizes flat_adjustment_cents' do
      expect(pricing_rule.flat_adjustment).to eq(Money.new(500))
    end
  end
end