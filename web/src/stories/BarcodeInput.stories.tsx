import type { Meta, StoryObj } from '@storybook/react';
import { BarcodeInput } from '../components/pos/BarcodeInput';
import { fn } from '@storybook/test';

const meta: Meta<typeof BarcodeInput> = {
  title: 'POS/BarcodeInput',
  component: BarcodeInput,
  parameters: { layout: 'padded' },
  args: {
    onScan: fn(),
  },
};

export default meta;
type Story = StoryObj<typeof BarcodeInput>;

export const Default: Story = {};

export const WithPlaceholder: Story = {
  args: {
    placeholder: 'Scan product barcode...',
  },
};

export const Disabled: Story = {
  args: {
    disabled: true,
  },
};
