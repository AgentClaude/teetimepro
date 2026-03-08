import type { Meta, StoryObj } from "@storybook/react";
import { MemoryRouter } from "react-router-dom";
import { RegisterForm } from "../components/auth/RegisterForm";
import { AuthProvider } from "../components/auth/AuthProvider";

const meta: Meta<typeof RegisterForm> = {
  title: "Auth/RegisterForm",
  component: RegisterForm,
  tags: ["autodocs"],
  decorators: [
    (Story) => (
      <MemoryRouter>
        <AuthProvider>
          <div className="mx-auto max-w-md rounded-xl bg-white p-8 shadow-sm">
            <Story />
          </div>
        </AuthProvider>
      </MemoryRouter>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof RegisterForm>;

export const Default: Story = {};
