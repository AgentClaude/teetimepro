require 'rails_helper'

RSpec.describe FnbTab, type: :model do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:user) { create(:user, organization: organization) }

  describe 'associations' do
    it { should belong_to(:organization) }
    it { should belong_to(:course) }
    it { should belong_to(:user) }
    it { should have_many(:fnb_tab_items).dependent(:destroy) }
    it { should have_many(:added_by_users).through(:fnb_tab_items) }
  end

  describe 'validations' do
    subject { build(:fnb_tab, organization: organization, course: course, user: user) }

    it { should validate_presence_of(:golfer_name) }
    it { should validate_length_of(:golfer_name).is_at_most(255) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[open closed merged]) }
    it { should validate_presence_of(:total_cents) }
    it { should validate_numericality_of(:total_cents).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:opened_at) }

    describe 'closed_at_after_opened_at' do
      it 'is valid when closed_at is after opened_at' do
        tab = build(:fnb_tab, organization: organization, course: course, user: user,
                   opened_at: 1.hour.ago, closed_at: Time.current)
        expect(tab).to be_valid
      end

      it 'is invalid when closed_at is before opened_at' do
        tab = build(:fnb_tab, organization: organization, course: course, user: user,
                   opened_at: Time.current, closed_at: 1.hour.ago)
        expect(tab).not_to be_valid
        expect(tab.errors[:closed_at]).to include('must be after opened at time')
      end
    end

    describe 'organization_consistency' do
      it 'is invalid when course does not belong to the same organization' do
        other_org = create(:organization)
        other_course = create(:course, organization: other_org)
        tab = build(:fnb_tab, organization: organization, course: other_course, user: user)
        
        expect(tab).not_to be_valid
        expect(tab.errors[:course]).to include('must belong to the same organization')
      end
    end
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(open: 'open', closed: 'closed', merged: 'merged') }
  end

  describe 'scopes' do
    let!(:open_tab) { create(:fnb_tab, organization: organization, course: course, user: user, status: 'open') }
    let!(:closed_tab) { create(:fnb_tab, organization: organization, course: course, user: user, status: 'closed') }
    let!(:other_org_tab) { create(:fnb_tab) }

    describe '.for_organization' do
      it 'returns tabs for the specified organization' do
        tabs = described_class.for_organization(organization)
        expect(tabs).to include(open_tab, closed_tab)
        expect(tabs).not_to include(other_org_tab)
      end
    end

    describe '.for_course' do
      it 'returns tabs for the specified course' do
        tabs = described_class.for_course(course)
        expect(tabs).to include(open_tab, closed_tab)
        expect(tabs).not_to include(other_org_tab)
      end
    end

    describe '.open_tabs' do
      it 'returns only open tabs' do
        tabs = described_class.open_tabs
        expect(tabs).to include(open_tab)
        expect(tabs).not_to include(closed_tab)
      end
    end
  end

  describe 'callbacks' do
    describe 'set_opened_at_if_blank' do
      it 'sets opened_at to current time if blank' do
        tab = build(:fnb_tab, organization: organization, course: course, user: user, opened_at: nil)
        expect { tab.valid? }.to change { tab.opened_at }.from(nil)
      end

      it 'does not change opened_at if already set' do
        time = 1.hour.ago
        tab = build(:fnb_tab, organization: organization, course: course, user: user, opened_at: time)
        expect { tab.valid? }.not_to change { tab.opened_at }
      end
    end

    describe 'calculate_total_cents' do
      it 'calculates total from tab items' do
        tab = create(:fnb_tab, organization: organization, course: course, user: user)
        create(:fnb_tab_item, fnb_tab: tab, quantity: 2, unit_price_cents: 1000, added_by: user)
        create(:fnb_tab_item, fnb_tab: tab, quantity: 1, unit_price_cents: 500, added_by: user)
        
        tab.send(:calculate_total_cents)
        expect(tab.total_cents).to eq(2500) # 2*1000 + 1*500
      end
    end
  end

  describe 'instance methods' do
    let(:tab) { create(:fnb_tab, organization: organization, course: course, user: user) }

    describe '#total_amount' do
      it 'returns Money object for total_cents' do
        tab.update(total_cents: 2500)
        expect(tab.total_amount).to be_a(Money)
        expect(tab.total_amount.cents).to eq(2500)
      end
    end

    describe '#open?' do
      it 'returns true for open status' do
        tab.update(status: 'open')
        expect(tab.open?).to be true
      end

      it 'returns false for non-open status' do
        tab.update(status: 'closed')
        expect(tab.open?).to be false
      end
    end

    describe '#duration_in_minutes' do
      it 'returns nil when not closed' do
        expect(tab.duration_in_minutes).to be_nil
      end

      it 'returns duration in minutes when closed' do
        tab.update(opened_at: 2.hours.ago, closed_at: 1.hour.ago)
        expect(tab.duration_in_minutes).to eq(60)
      end
    end

    describe '#item_count' do
      it 'returns sum of quantities of all items' do
        create(:fnb_tab_item, fnb_tab: tab, quantity: 2, added_by: user)
        create(:fnb_tab_item, fnb_tab: tab, quantity: 3, added_by: user)
        
        expect(tab.item_count).to eq(5)
      end
    end

    describe '#can_be_modified?' do
      it 'returns true for open tabs' do
        tab.update(status: 'open')
        expect(tab.can_be_modified?).to be true
      end

      it 'returns false for closed tabs' do
        tab.update(status: 'closed')
        expect(tab.can_be_modified?).to be false
      end

      it 'returns false for merged tabs' do
        tab.update(status: 'merged')
        expect(tab.can_be_modified?).to be false
      end
    end

    describe '#close!' do
      it 'updates status to closed and sets closed_at' do
        freeze_time do
          tab.close!
          expect(tab.status).to eq('closed')
          expect(tab.closed_at).to be_within(1.second).of(Time.current)
        end
      end
    end

    describe '#merge!' do
      it 'updates status to merged and sets closed_at' do
        freeze_time do
          tab.merge!
          expect(tab.status).to eq('merged')
          expect(tab.closed_at).to be_within(1.second).of(Time.current)
        end
      end
    end
  end
end
