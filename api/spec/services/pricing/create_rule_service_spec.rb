require 'rails_helper'

RSpec.describe Pricing::CreateRuleService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization, role: :admin) }
  let(:course) { create(:course, organization: organization) }

  let(:valid_params) do
    {
      organization: organization,
      user: user,
      name: 'Weekend Premium',
      rule_type: 'day_of_week',
      conditions: { days: ['saturday', 'sunday'] },
      multiplier: 1.25,
      priority: 100
    }
  end

  describe '#call' do
    subject(:service) { described_class.call(valid_params) }

    context 'with valid parameters' do
      it 'creates a pricing rule successfully' do
        expect { service }.to change(PricingRule, :count).by(1)
        
        expect(service).to be_success
        pricing_rule = service.pricing_rule
        expect(pricing_rule.name).to eq('Weekend Premium')
        expect(pricing_rule.rule_type).to eq('day_of_week')
        expect(pricing_rule.organization).to eq(organization)
        expect(pricing_rule.multiplier).to eq(1.25)
        expect(pricing_rule).to be_active
      end
    end

    context 'with course_id specified' do
      let(:params_with_course) { valid_params.merge(course_id: course.id) }
      subject(:service) { described_class.call(params_with_course) }

      it 'associates the rule with the course' do
        expect(service).to be_success
        expect(service.pricing_rule.course).to eq(course)
      end
    end

    context 'with flat adjustment' do
      let(:params_with_flat) do
        valid_params.merge(
          flat_adjustment_cents: 500,
          multiplier: 1.0
        )
      end
      subject(:service) { described_class.call(params_with_flat) }

      it 'creates rule with flat adjustment' do
        expect(service).to be_success
        expect(service.pricing_rule.flat_adjustment_cents).to eq(500)
        expect(service.pricing_rule.multiplier).to eq(1.0)
      end
    end

    context 'with date range' do
      let(:params_with_dates) do
        valid_params.merge(
          start_date: Date.current,
          end_date: 30.days.from_now.to_date
        )
      end
      subject(:service) { described_class.call(params_with_dates) }

      it 'creates rule with date range' do
        expect(service).to be_success
        pricing_rule = service.pricing_rule
        expect(pricing_rule.start_date).to eq(Date.current)
        expect(pricing_rule.end_date).to eq(30.days.from_now.to_date)
      end
    end

    context 'when user is not authorized' do
      let(:unauthorized_user) { create(:user, organization: organization, role: :golfer) }
      let(:params) { valid_params.merge(user: unauthorized_user) }
      subject(:service) { described_class.call(params) }

      it 'returns authorization error' do
        expect(service).to be_failure
        expect(service.errors).to include('Insufficient permissions')
      end
    end

    context 'when user belongs to different organization' do
      let(:other_org) { create(:organization) }
      let(:other_user) { create(:user, organization: other_org, role: :admin) }
      let(:params) { valid_params.merge(user: other_user) }
      subject(:service) { described_class.call(params) }

      it 'returns authorization error' do
        expect(service).to be_failure
        expect(service.errors).to include('User does not belong to this organization')
      end
    end

    context 'when course belongs to different organization' do
      let(:other_org) { create(:organization) }
      let(:other_course) { create(:course, organization: other_org) }
      let(:params) { valid_params.merge(course_id: other_course.id) }
      subject(:service) { described_class.call(params) }

      it 'returns error' do
        expect(service).to be_failure
        expect(service.errors).to include('Course not found or doesn\'t belong to organization')
      end
    end

    context 'with missing required parameters' do
      context 'when name is missing' do
        let(:params) { valid_params.merge(name: nil) }
        subject(:service) { described_class.call(params) }

        it 'returns validation error' do
          expect(service).to be_failure
          expect(service.errors).to include('Name can\'t be blank')
        end
      end

      context 'when rule_type is missing' do
        let(:params) { valid_params.merge(rule_type: nil) }
        subject(:service) { described_class.call(params) }

        it 'returns validation error' do
          expect(service).to be_failure
          expect(service.errors).to include('Rule type can\'t be blank')
        end
      end

      context 'when rule_type is invalid' do
        let(:params) { valid_params.merge(rule_type: 'invalid_type') }
        subject(:service) { described_class.call(params) }

        it 'returns validation error' do
          expect(service).to be_failure
          expect(service.errors).to include('Rule type is not included in the list')
        end
      end

      context 'when multiplier is invalid' do
        let(:params) { valid_params.merge(multiplier: 0) }
        subject(:service) { described_class.call(params) }

        it 'returns validation error' do
          expect(service).to be_failure
          expect(service.errors).to include('Multiplier must be greater than 0')
        end
      end

      context 'when priority is negative' do
        let(:params) { valid_params.merge(priority: -1) }
        subject(:service) { described_class.call(params) }

        it 'returns validation error' do
          expect(service).to be_failure
          expect(service.errors).to include('Priority must be greater than or equal to 0')
        end
      end
    end

    context 'with invalid date range' do
      let(:params) do
        valid_params.merge(
          start_date: Date.current,
          end_date: 1.day.ago.to_date
        )
      end
      subject(:service) { described_class.call(params) }

      it 'returns validation error' do
        expect(service).to be_failure
        expect(service.errors).to include('End date must be after start date')
      end
    end

    context 'when inactive is specified' do
      let(:params) { valid_params.merge(active: false) }
      subject(:service) { described_class.call(params) }

      it 'creates inactive rule' do
        expect(service).to be_success
        expect(service.pricing_rule).not_to be_active
      end
    end
  end
end