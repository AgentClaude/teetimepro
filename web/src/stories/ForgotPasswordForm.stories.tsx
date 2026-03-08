import type { Meta, StoryObj } from "@storybook/react";
import { MemoryRouter } from "react-router-dom";
import { ForgotPasswordForm } from "../components/auth/ForgotPasswordForm";

const meta: Meta<typeof ForgotPasswordForm> = {
  title: "Auth/ForgotPasswordForm",
  component: ForgotPasswordForm,
  tags: ["autodocs"],
  decorators: [
    (Story) => (
      <MemoryRouter>
        <div className="mx-auto max-w-md rounded-xl bg-white p-8 shadow-sm">
          <Story />
        </div>
      </MemoryRouter>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof ForgotPasswordForm>;

export const Default: Story = {};
