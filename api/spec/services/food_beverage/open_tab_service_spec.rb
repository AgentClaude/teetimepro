require 'rails_helper'

RSpec.describe FoodBeverage::OpenTabService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:course) { create(:course, organization: organization) }

  describe '.call' do
    context 'with valid params' do
      it 'creates a new tab successfully' do
        result = described_class.call(
          organization: organization,
          user: user,
          golfer_name: 'John Doe',
          course_id: course.id
        )

        expect(result).to be_success
        expect(result.tab).to be_a(FnbTab)
        expect(result.tab.golfer_name).to eq('John Doe')
        expect(result.tab.status).to eq('open')
        expect(result.tab.total_cents).to eq(0)
        expect(result.tab.organization).to eq(organization)
        expect(result.tab.course).to eq(course)
        expect(result.tab.user).to eq(user)
        expect(result.tab.opened_at).to be_present
        expect(result.tab.closed_at).to be_nil
      end

      it 'strips whitespace from golfer name' do
        result = described_class.call(
          organization: organization,
          user: user,
          golfer_name: '  John Doe  ',
          course_id: course.id
        )

        expect(result).to be_success
        expect(result.tab.golfer_name).to eq('John Doe')
      end

      it 'broadcasts real-time notification' do
        expect(ActionCable.server).to receive(:broadcast).with(
          "fnb_tabs_#{organization.id}",
          hash_including(
            type: 'tab.opened',
            tab: hash_including(
              golfer_name: 'John Doe',
              course_name: course.name,
              server_name: user.full_name
            )
          )
        )

        described_class.call(
          organization: organization,
          user: user,
          golfer_name: 'John Doe',
          course_id: course.id
        )
      end
    end

    context 'with invalid params' do
      it 'fails when organization is missing' do
        result = described_class.call(
          organization: nil,
          user: user,
          golfer_name: 'John Doe',
          course_id: course.id
        )

        expect(result).to be_failure
        expect(result.errors).to include('Organization can\'t be blank')
      end

      it 'fails when user is missing' do
        result = described_class.call(
          organization: organization,
          user: nil,
          golfer_name: 'John Doe',
          course_id: course.id
        )

        expect(result).to be_failure
        expect(result.errors).to include('User can\'t be blank')
      end

      it 'fails when golfer_name is missing' do
        result = described_class.call(
          organization: organization,
          user: user,
          golfer_name: '',
          course_id: course.id
        )

        expect(result).to be_failure
        expect(result.errors).to include('Golfer name can\'t be blank')
      end

      it 'fails when course_id is missing' do
        result = described_class.call(
          organization: organization,
          user: user,
          golfer_name: 'John Doe',
          course_id: nil
        )

        expect(result).to be_failure
        expect(result.errors).to include('Course can\'t be blank')
      end

      it 'fails when course does not exist' do
        result = described_class.call(
          organization: organization,
          user: user,
          golfer_name: 'John Doe',
          course_id: 99999
        )

        expect(result).to be_failure
        expect(result.errors).to include('Course not found')
      end

      it 'fails when course belongs to different organization' do
        other_org = create(:organization)
        other_course = create(:course, organization: other_org)

        result = described_class.call(
          organization: organization,
          user: user,
          golfer_name: 'John Doe',
          course_id: other_course.id
        )

        expect(result).to be_failure
        expect(result.errors).to include('Course not found')
      end

      it 'fails when user belongs to different organization' do
        other_org = create(:organization)
        other_user = create(:user, organization: other_org)

        expect {
          described_class.call(
            organization: organization,
            user: other_user,
            golfer_name: 'John Doe',
            course_id: course.id
          )
        }.to raise_error(AuthorizationError, 'User does not belong to this organization')
      end
    end

    context 'when database error occurs' do
      it 'handles ActiveRecord::RecordInvalid' do
        allow(FnbTab).to receive(:create!).and_raise(
          ActiveRecord::RecordInvalid.new(FnbTab.new)
        )

        result = described_class.call(
          organization: organization,
          user: user,
          golfer_name: 'John Doe',
          course_id: course.id
        )

        expect(result).to be_failure
        expect(result.errors.first).to include('Record invalid')
      end
    end
  end
end
