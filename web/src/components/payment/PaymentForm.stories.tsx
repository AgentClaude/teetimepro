import type { Meta, StoryObj } from '@storybook/react';
import { PaymentForm } from './PaymentForm';
import { StripeProvider } from './StripeProvider';

const meta: Meta<typeof PaymentForm> = {
  title: 'Payment/PaymentForm',
  component: PaymentForm,
  tags: ['autodocs'],
  decorators: [
    (Story: any) => (
      <StripeProvider>
        <div className="max-w-md mx-auto p-6">
          <div className="border border-dashed border-gray-300 rounded-lg p-4 text-center text-gray-500 mb-6">
            Note: Stripe Elements would render here in a real environment.
            <br />
            This is a mock for Storybook demonstration.
          </div>
          <Story />
        </div>
      </StripeProvider>
    ),
  ],
  parameters: {
    docs: {
      description: {
        component: 'Payment form component that integrates with Stripe Elements. Note: Requires valid Stripe configuration to function properly.',
      },
    },
  },
  argTypes: {
    amount: {
      control: { type: 'number', min: 100 },
      description: 'Amount in cents',
    },
  },
};

export default meta;
type Story = StoryObj<typeof PaymentForm>;

export const Default: Story = {
  args: {
    clientSecret: 'pi_test_1234567890_secret_test',
    amount: 8500, // $85.00
    onSuccess: (paymentMethodId: string) => console.log('Payment successful:', paymentMethodId),
    onError: (error: string) => console.error('Payment error:', error),
    loading: false,
  },
};

export const SmallAmount: Story = {
  args: {
    clientSecret: 'pi_test_small_secret_test',
    amount: 2000, // $20.00
    onSuccess: (paymentMethodId: string) => console.log('Payment successful:', paymentMethodId),
    onError: (error: string) => console.error('Payment error:', error),
    loading: false,
  },
};

export const LargeAmount: Story = {
  args: {
    clientSecret: 'pi_test_large_secret_test',
    amount: 25000, // $250.00
    onSuccess: (paymentMethodId: string) => console.log('Payment successful:', paymentMethodId),
    onError: (error: string) => console.error('Payment error:', error),
    loading: false,
  },
};

export const Loading: Story = {
  args: {
    clientSecret: 'pi_test_loading_secret_test',
    amount: 8500,
    onSuccess: (paymentMethodId: string) => console.log('Payment successful:', paymentMethodId),
    onError: (error: string) => console.error('Payment error:', error),
    loading: true,
  },
};