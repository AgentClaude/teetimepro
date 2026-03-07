import type { Meta, StoryObj } from '@storybook/react';
import { NewChargeDialog } from './NewChargeDialog';
import type { NewChargeData } from './NewChargeDialog';

const meta: Meta<typeof NewChargeDialog> = {
  title: 'Member Accounts/NewChargeDialog',
  component: NewChargeDialog,
  tags: ['autodocs'],
  parameters: {
    layout: 'fullscreen',
  },
};

export default meta;
type Story = StoryObj<typeof NewChargeDialog>;

export const Default: Story = {
  args: {
    memberName: 'John Smith',
    availableCreditCents: 498_500,
    onSubmit: (data: NewChargeData) => alert(JSON.stringify(data, null, 2)),
    onCancel: () => alert('Cancelled'),
  },
};

export const LowCredit: Story = {
  args: {
    memberName: 'Jane Doe',
    availableCreditCents: 25_00,
    onSubmit: (data: NewChargeData) => alert(JSON.stringify(data, null, 2)),
    onCancel: () => alert('Cancelled'),
  },
};

export const Loading: Story = {
  args: {
    memberName: 'John Smith',
    availableCreditCents: 498_500,
    onSubmit: () => {},
    onCancel: () => {},
    loading: true,
  },
};
