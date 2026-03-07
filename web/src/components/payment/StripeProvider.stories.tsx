import type { Meta, StoryObj } from '@storybook/react';
import { StripeProvider } from './StripeProvider';

const meta: Meta<typeof StripeProvider> = {
  title: 'Payment/StripeProvider',
  component: StripeProvider,
  tags: ['autodocs'],
  parameters: {
    docs: {
      description: {
        component: 'Provides Stripe Elements context with custom styling that matches the app theme.',
      },
    },
  },
};

export default meta;
type Story = StoryObj<typeof StripeProvider>;

export const Default: Story = {
  args: {
    children: (
      <div className="p-6 max-w-md mx-auto">
        <h3 className="text-lg font-medium mb-4">Stripe Provider Content</h3>
        <div className="border border-dashed border-gray-300 rounded-lg p-4 text-center text-gray-500">
          Any Stripe Elements components would be rendered here.
          <br />
          <span className="text-sm">
            (Provider is configured with green theme to match app)
          </span>
        </div>
      </div>
    ),
  },
};

export const WithClientSecret: Story = {
  args: {
    clientSecret: 'pi_test_1234567890_secret_test',
    children: (
      <div className="p-6 max-w-md mx-auto">
        <h3 className="text-lg font-medium mb-4">With Payment Intent</h3>
        <div className="border border-dashed border-gray-300 rounded-lg p-4 text-center text-gray-500">
          Elements are configured with a client secret.
          <br />
          <span className="text-sm">
            Ready for payment confirmation.
          </span>
          <br />
          <span className="text-xs font-mono mt-2 block">
            pi_test_1234567890...
          </span>
        </div>
      </div>
    ),
  },
};

export const ThemePreview: Story = {
  args: {
    children: (
      <div className="p-6 max-w-md mx-auto space-y-4">
        <h3 className="text-lg font-medium">Stripe Theme Configuration</h3>
        <div className="space-y-2 text-sm">
          <div className="flex justify-between">
            <span>Primary Color:</span>
            <div className="flex items-center gap-2">
              <div className="w-4 h-4 bg-green-500 rounded"></div>
              <span className="font-mono">#10B981</span>
            </div>
          </div>
          <div className="flex justify-between">
            <span>Background:</span>
            <div className="flex items-center gap-2">
              <div className="w-4 h-4 bg-white border rounded"></div>
              <span className="font-mono">#ffffff</span>
            </div>
          </div>
          <div className="flex justify-between">
            <span>Text:</span>
            <div className="flex items-center gap-2">
              <div className="w-4 h-4 bg-gray-700 rounded"></div>
              <span className="font-mono">#374151</span>
            </div>
          </div>
          <div className="flex justify-between">
            <span>Border Radius:</span>
            <span className="font-mono">8px</span>
          </div>
        </div>
      </div>
    ),
  },
};