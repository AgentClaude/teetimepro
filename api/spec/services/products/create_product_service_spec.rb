require 'rails_helper'

RSpec.describe Products::CreateProductService, type: :service do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:user) { create(:user, organization: organization, role: :manager) }

  describe '#call' do
    context 'with valid parameters' do
      let(:service_params) do
        {
          organization: organization,
          course: course,
          name: 'Golf Balls',
          sku: 'GB001',
          price_cents: 1500,
          category: 'equipment',
          description: 'Premium golf balls',
          track_inventory: true,
          reorder_point: 10,
          reorder_quantity: 50,
          initial_stock: 25,
          performed_by: user
        }
      end

      it 'creates a product' do
        expect {
          Products::CreateProductService.call(service_params)
        }.to change(PosProduct, :count).by(1)
      end

      it 'creates inventory level when tracking inventory' do
        expect {
          Products::CreateProductService.call(service_params)
        }.to change(InventoryLevel, :count).by(1)
      end

      it 'creates initial stock movement when initial_stock provided' do
        expect {
          Products::CreateProductService.call(service_params)
        }.to change(InventoryMovement, :count).by(1)
      end

      it 'returns success result with created objects' do
        result = Products::CreateProductService.call(service_params)

        expect(result.success?).to be true
        expect(result.product.name).to eq('Golf Balls')
        expect(result.product.track_inventory).to be true
        expect(result.inventory_level.reorder_point).to eq(10)
        expect(result.initial_movement.quantity).to eq(25)
      end

      context 'without inventory tracking' do
        it 'does not create inventory level' do
          expect {
            Products::CreateProductService.call(service_params.merge(track_inventory: false))
          }.not_to change(InventoryLevel, :count)
        end
      end
    end

    context 'with invalid parameters' do
      it 'fails when name is missing' do
        result = Products::CreateProductService.call(
          organization: organization,
          course: course,
          sku: 'GB001',
          price_cents: 1500,
          performed_by: user
        )

        expect(result.failure?).to be true
        expect(result.errors).to include("Name can't be blank")
      end

      it 'fails when price is negative' do
        result = Products::CreateProductService.call(
          organization: organization,
          course: course,
          name: 'Golf Balls',
          sku: 'GB001',
          price_cents: -100,
          performed_by: user
        )

        expect(result.failure?).to be true
        expect(result.errors).to include("Price cents must be greater than or equal to 0")
      end
    end
  end
end