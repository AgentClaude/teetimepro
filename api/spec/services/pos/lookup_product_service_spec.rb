require 'rails_helper'

RSpec.describe Pos::LookupProductService do
  let(:org) { create(:organization) }
  let(:course) { create(:course, organization: org) }

  describe '.call' do
    context 'with a valid barcode' do
      let!(:product) { create(:pos_product, organization: org, course: course, barcode: '1234567890') }

      it 'finds the product by barcode' do
        result = described_class.call(organization: org, code: '1234567890')
        expect(result).to be_success
        expect(result.data[:product]).to eq(product)
      end
    end

    context 'with a valid SKU' do
      let!(:product) { create(:pos_product, organization: org, course: course, sku: 'GOLF-001') }

      it 'finds the product by SKU' do
        result = described_class.call(organization: org, code: 'GOLF-001')
        expect(result).to be_success
        expect(result.data[:product]).to eq(product)
      end
    end

    context 'with whitespace in code' do
      let!(:product) { create(:pos_product, organization: org, course: course, barcode: '1234567890') }

      it 'trims whitespace' do
        result = described_class.call(organization: org, code: '  1234567890  ')
        expect(result).to be_success
        expect(result.data[:product]).to eq(product)
      end
    end

    context 'with an unknown code' do
      it 'returns failure' do
        result = described_class.call(organization: org, code: 'UNKNOWN')
        expect(result).not_to be_success
        expect(result.errors).to include('Product not found')
      end
    end

    context 'with an inactive product' do
      let!(:product) { create(:pos_product, :inactive, organization: org, course: course, barcode: '1234567890') }

      it 'returns failure' do
        result = described_class.call(organization: org, code: '1234567890')
        expect(result).not_to be_success
        expect(result.errors).to include('Product not found')
      end
    end

    context 'with an out-of-stock product' do
      let!(:product) { create(:pos_product, :out_of_stock, organization: org, course: course, barcode: '1234567890') }

      it 'returns failure' do
        result = described_class.call(organization: org, code: '1234567890')
        expect(result).not_to be_success
        expect(result.errors).to include('Product is out of stock')
      end
    end

    context 'with missing params' do
      it 'returns validation failure when code is blank' do
        result = described_class.call(organization: org, code: nil)
        expect(result).not_to be_success
      end

      it 'returns validation failure when organization is blank' do
        result = described_class.call(organization: nil, code: '123')
        expect(result).not_to be_success
      end
    end
  end
end
