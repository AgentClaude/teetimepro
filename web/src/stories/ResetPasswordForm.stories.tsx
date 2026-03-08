import type { Meta, StoryObj } from "@storybook/react";
import { MemoryRouter } from "react-router-dom";
import { ResetPasswordForm } from "../components/auth/ResetPasswordForm";

const meta: Meta<typeof ResetPasswordForm> = {
  title: "Auth/ResetPasswordForm",
  component: ResetPasswordForm,
  tags: ["autodocs"],
  decorators: [
    (Story) => (
      <MemoryRouter initialEntries={["/reset-password?token=test-token"]}>
        <div className="mx-auto max-w-md rounded-xl bg-white p-8 shadow-sm">
          <Story />
        </div>
      </MemoryRouter>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof ResetPasswordForm>;

export const Default: Story = {};

export const InvalidToken: Story = {
  decorators: [
    (Story) => (
      <MemoryRouter initialEntries={["/reset-password"]}>
        <div className="mx-auto max-w-md rounded-xl bg-white p-8 shadow-sm">
          <Story />
        </div>
      </MemoryRouter>
    ),
  ],
};
