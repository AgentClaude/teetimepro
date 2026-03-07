require 'rails_helper'

RSpec.describe Inventory::AdjustStockService, type: :service do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:product) { create(:pos_product, organization: organization, course: course) }
  let(:user) { create(:user, organization: organization, role: :manager) }

  describe '#call' do
    context 'with valid parameters' do
      let(:service_params) do
        {
          product: product,
          course: course,
          quantity: 5,
          notes: 'Manual stock adjustment',
          performed_by: user,
          unit_cost_cents: 250
        }
      end

      it 'creates an inventory movement' do
        expect {
          Inventory::AdjustStockService.call(service_params)
        }.to change(InventoryMovement, :count).by(1)
      end

      it 'returns success result with movement and inventory level' do
        result = Inventory::AdjustStockService.call(service_params)

        expect(result.success?).to be true
        expect(result.movement).to be_an(InventoryMovement)
        expect(result.movement.movement_type).to eq('adjustment')
        expect(result.movement.quantity).to eq(5)
        expect(result.movement.notes).to eq('Manual stock adjustment')
        expect(result.movement.unit_cost_cents).to eq(250)
        expect(result.inventory_level).to be_present
      end

      it 'calculates total cost correctly' do
        result = Inventory::AdjustStockService.call(service_params)

        expect(result.movement.total_cost_cents).to eq(1250) # 250 * 5
      end

      context 'with negative adjustment' do
        it 'handles negative quantity adjustments' do
          result = Inventory::AdjustStockService.call(service_params.merge(quantity: -3))

          expect(result.success?).to be true
          expect(result.movement.quantity).to eq(-3)
        end
      end

      context 'without unit cost' do
        it 'creates movement without cost information' do
          result = Inventory::AdjustStockService.call(service_params.except(:unit_cost_cents))

          expect(result.success?).to be true
          expect(result.movement.unit_cost_cents).to be_nil
          expect(result.movement.total_cost_cents).to be_nil
        end
      end
    end

    context 'with invalid parameters' do
      it 'fails when product is missing' do
        result = Inventory::AdjustStockService.call(
          course: course,
          quantity: 5,
          performed_by: user
        )

        expect(result.failure?).to be true
        expect(result.errors).to include("Product can't be blank")
      end

      it 'fails when course is missing' do
        result = Inventory::AdjustStockService.call(
          product: product,
          quantity: 5,
          performed_by: user
        )

        expect(result.failure?).to be true
        expect(result.errors).to include("Course can't be blank")
      end

      it 'fails when quantity is zero' do
        result = Inventory::AdjustStockService.call(
          product: product,
          course: course,
          quantity: 0,
          performed_by: user
        )

        expect(result.failure?).to be true
        expect(result.errors).to include("Quantity must be other than 0")
      end

      it 'fails when performed_by is missing' do
        result = Inventory::AdjustStockService.call(
          product: product,
          course: course,
          quantity: 5
        )

        expect(result.failure?).to be true
        expect(result.errors).to include("Performed by can't be blank")
      end
    end

    context 'authorization' do
      let(:other_organization) { create(:organization) }
      let(:other_user) { create(:user, organization: other_organization) }

      it 'fails when user does not belong to product organization' do
        result = Inventory::AdjustStockService.call(
          product: product,
          course: course,
          quantity: 5,
          performed_by: other_user
        )

        expect(result.failure?).to be true
        expect(result.errors).to include('User does not belong to this organization')
      end
    end

    context 'when movement creation fails' do
      it 'handles validation errors gracefully' do
        # Create movement with invalid course from different organization
        other_org = create(:organization)
        other_course = create(:course, organization: other_org)

        result = Inventory::AdjustStockService.call(
          product: product,
          course: other_course,
          quantity: 5,
          performed_by: user
        )

        expect(result.failure?).to be true
        expect(result.errors).to be_present
      end
    end
  end
end