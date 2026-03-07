require 'rails_helper'

RSpec.describe Pricing::CalculatePriceService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.current) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, price_cents: 5000) } # $50 base price

  describe '#call' do
    subject(:service) { described_class.call(tee_time: tee_time) }

    context 'when tee_time is missing' do
      subject(:service) { described_class.call(tee_time: nil) }

      it 'returns validation failure' do
        expect(service).to be_failure
        expect(service.errors).to include('Tee time can\'t be blank')
      end
    end

    context 'when tee_time has no base price' do
      before { tee_time.update!(price_cents: 0) }

      it 'returns failure' do
        expect(service).to be_failure
        expect(service.errors).to include('Tee time has no base price')
      end
    end

    context 'with no applicable rules' do
      it 'returns the base price' do
        expect(service).to be_success
        expect(service.original_price_cents).to eq(5000)
        expect(service.dynamic_price_cents).to eq(5000)
        expect(service.price_adjustment_cents).to eq(0)
        expect(service.applied_rules).to be_empty
        expect(service.price_breakdown).to have_attributes(size: 1)
      end
    end

    context 'with a single applicable rule' do
      before do
        create(:pricing_rule, 
               organization: organization,
               rule_type: 'day_of_week',
               conditions: { days: [Date.current.strftime('%A').downcase] },
               multiplier: 1.25)
      end

      it 'applies the rule correctly' do
        expect(service).to be_success
        expect(service.original_price_cents).to eq(5000)
        expect(service.dynamic_price_cents).to eq(6250) # 5000 * 1.25
        expect(service.price_adjustment_cents).to eq(1250)
        expect(service.applied_rules).to have_attributes(size: 1)
        expect(service.price_breakdown).to have_attributes(size: 2)
      end
    end

    context 'with multiple stacking rules' do
      before do
        # Weekend rule (25% increase)
        create(:pricing_rule, 
               organization: organization,
               rule_type: 'day_of_week',
               conditions: { days: [Date.current.strftime('%A').downcase] },
               multiplier: 1.25,
               priority: 100)

        # Peak time rule (15% increase)
        create(:pricing_rule, 
               organization: organization,
               rule_type: 'time_of_day',
               conditions: { hours: { start: 0, end: 23 } }, # Always applicable for test
               multiplier: 1.15,
               priority: 90)

        # Flat adjustment rule ($5 surcharge)
        create(:pricing_rule, 
               organization: organization,
               rule_type: 'advance_booking',
               conditions: { hours: 0, operator: 'greater_than' }, # Always applicable for test
               multiplier: 1.0,
               flat_adjustment_cents: 500,
               priority: 80)
      end

      it 'stacks multipliers and adds flat adjustments' do
        expect(service).to be_success
        expect(service.original_price_cents).to eq(5000)
        # (5000 * 1.25 * 1.15) + 500 = 7687 + 500 = 8187
        expected_price = (5000 * 1.25 * 1.15).round + 500
        expect(service.dynamic_price_cents).to eq(expected_price)
        expect(service.applied_rules).to have_attributes(size: 3)
        expect(service.price_breakdown).to have_attributes(size: 4) # base + 3 rules
      end
    end

    context 'with last minute discount' do
      before do
        # Create a tee time that starts in 1 hour
        future_time = 1.hour.from_now
        tee_time.update!(starts_at: future_time)

        create(:pricing_rule,
               organization: organization,
               rule_type: 'last_minute',
               conditions: { hours: 2 },
               multiplier: 0.75)
      end

      it 'applies the discount correctly' do
        expect(service).to be_success
        expect(service.dynamic_price_cents).to eq(3750) # 5000 * 0.75
        expect(service.price_adjustment_cents).to eq(-1250)
      end
    end

    context 'with occupancy-based pricing' do
      let!(:other_tee_times) do
        # Create 4 more tee times on the same sheet, all fully booked
        create_list(:tee_time, 4, 
                   tee_sheet: tee_sheet, 
                   max_players: 4, 
                   booked_players: 4)
      end

      before do
        # Current tee_time has default max_players: 4, booked_players: 0
        # So total: 20 max players, 16 booked = 80% occupancy
        create(:pricing_rule,
               organization: organization,
               rule_type: 'occupancy',
               conditions: { threshold: 75, operator: 'greater_than' },
               multiplier: 1.10)
      end

      it 'applies occupancy-based pricing' do
        expect(service).to be_success
        expect(service.dynamic_price_cents).to eq(5500) # 5000 * 1.10
      end
    end

    context 'with course-specific rules' do
      let(:other_course) { create(:course, organization: organization) }
      
      before do
        # Rule for different course
        create(:pricing_rule, 
               organization: organization,
               course: other_course,
               multiplier: 1.50)

        # Rule for our course
        create(:pricing_rule, 
               organization: organization,
               course: course,
               multiplier: 1.25)

        # Organization-wide rule
        create(:pricing_rule, 
               organization: organization,
               course: nil,
               multiplier: 1.10)
      end

      it 'applies only applicable course rules' do
        expect(service).to be_success
        # Should apply both course-specific (1.25) and org-wide (1.10) rules
        # but not the other course rule
        expected_price = (5000 * 1.25 * 1.10).round
        expect(service.dynamic_price_cents).to eq(expected_price)
        expect(service.applied_rules).to have_attributes(size: 2)
      end
    end

    context 'with date range restrictions' do
      before do
        # Rule that's not yet active
        create(:pricing_rule,
               organization: organization,
               start_date: 1.day.from_now.to_date,
               end_date: 5.days.from_now.to_date,
               multiplier: 1.50)

        # Rule that's currently active
        create(:pricing_rule,
               organization: organization,
               start_date: 1.day.ago.to_date,
               end_date: 1.day.from_now.to_date,
               multiplier: 1.25)

        # Rule that has expired
        create(:pricing_rule,
               organization: organization,
               start_date: 5.days.ago.to_date,
               end_date: 2.days.ago.to_date,
               multiplier: 2.0)
      end

      it 'applies only currently valid rules' do
        expect(service).to be_success
        expect(service.dynamic_price_cents).to eq(6250) # 5000 * 1.25
        expect(service.applied_rules).to have_attributes(size: 1)
      end
    end

    context 'with inactive rules' do
      before do
        create(:pricing_rule, 
               organization: organization,
               active: false,
               multiplier: 1.50)

        create(:pricing_rule, 
               organization: organization,
               active: true,
               multiplier: 1.25)
      end

      it 'ignores inactive rules' do
        expect(service).to be_success
        expect(service.dynamic_price_cents).to eq(6250) # 5000 * 1.25
        expect(service.applied_rules).to have_attributes(size: 1)
      end
    end

    context 'with rules from different organizations' do
      let(:other_org) { create(:organization) }
      
      before do
        create(:pricing_rule, 
               organization: other_org,
               multiplier: 2.0)

        create(:pricing_rule, 
               organization: organization,
               multiplier: 1.25)
      end

      it 'applies only rules from the tee time\'s organization' do
        expect(service).to be_success
        expect(service.dynamic_price_cents).to eq(6250) # 5000 * 1.25
        expect(service.applied_rules).to have_attributes(size: 1)
      end
    end

    context 'when price would go negative' do
      before do
        create(:pricing_rule,
               organization: organization,
               multiplier: 0.5)
        
        create(:pricing_rule,
               organization: organization,
               flat_adjustment_cents: -4000) # -$40
      end

      it 'prevents negative pricing' do
        expect(service).to be_success
        # (5000 * 0.5) - 4000 = 2500 - 4000 = -1500, should become 0
        expect(service.dynamic_price_cents).to eq(0)
        expect(service.price_adjustment_cents).to eq(-5000)
      end
    end

    context 'with priority ordering' do
      before do
        # Lower priority applied first
        create(:pricing_rule,
               organization: organization,
               multiplier: 1.10,
               priority: 50)

        # Higher priority applied second  
        create(:pricing_rule,
               organization: organization,
               multiplier: 1.20,
               priority: 100)
      end

      it 'applies rules in priority order (highest first)' do
        expect(service).to be_success
        # Should apply 1.20 first, then 1.10
        # 5000 * 1.20 * 1.10 = 6600
        expected_price = (5000 * 1.20 * 1.10).round
        expect(service.dynamic_price_cents).to eq(expected_price)

        # Verify order in breakdown
        breakdown = service.price_breakdown
        expect(breakdown[1][:multiplier]).to eq(1.20) # Higher priority first
        expect(breakdown[2][:multiplier]).to eq(1.10) # Lower priority second
      end
    end
  end
end