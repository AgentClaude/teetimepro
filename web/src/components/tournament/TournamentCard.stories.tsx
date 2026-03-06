import type { Meta, StoryObj } from "@storybook/react";
import { TournamentCard } from "./TournamentCard";

const meta: Meta<typeof TournamentCard> = {
  title: "Tournament/TournamentCard",
  component: TournamentCard,
  parameters: {
    layout: "padded",
  },
  decorators: [
    (Story: React.ComponentType) => (
      <div className="max-w-sm">
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof TournamentCard>;

export const RegistrationOpen: Story = {
  args: {
    id: "1",
    name: "Spring Classic 2026",
    format: "STROKE",
    status: "REGISTRATION_OPEN",
    startDate: "2026-04-15",
    endDate: "2026-04-15",
    courseName: "Pine Valley Golf Course",
    entriesCount: 34,
    maxParticipants: 72,
    entryFeeDisplay: "$50.00",
    holes: 18,
    registrationAvailable: true,
  },
};

export const Scramble: Story = {
  args: {
    id: "2",
    name: "Charity Scramble",
    format: "SCRAMBLE",
    status: "REGISTRATION_OPEN",
    startDate: "2026-05-01",
    endDate: "2026-05-01",
    courseName: "Oakmont Country Club",
    entriesCount: 60,
    maxParticipants: 72,
    entryFeeDisplay: "$100.00",
    holes: 18,
    registrationAvailable: true,
  },
};

export const MultiDay: Story = {
  args: {
    id: "3",
    name: "Summer Championship",
    format: "MATCH_PLAY",
    status: "REGISTRATION_CLOSED",
    startDate: "2026-06-10",
    endDate: "2026-06-12",
    courseName: "Augusta National",
    entriesCount: 64,
    maxParticipants: 64,
    entryFeeDisplay: "$250.00",
    holes: 18,
    registrationAvailable: false,
  },
};

export const InProgress: Story = {
  args: {
    id: "4",
    name: "Member-Guest Invitational",
    format: "BEST_BALL",
    status: "IN_PROGRESS",
    startDate: "2026-03-06",
    endDate: "2026-03-07",
    courseName: "Pebble Beach",
    entriesCount: 48,
    maxParticipants: 48,
    entryFeeDisplay: "$150.00",
    holes: 18,
    registrationAvailable: false,
  },
};

export const Completed: Story = {
  args: {
    id: "5",
    name: "Winter Open",
    format: "STROKE",
    status: "COMPLETED",
    startDate: "2026-01-15",
    endDate: "2026-01-15",
    courseName: "St Andrews",
    entriesCount: 56,
    maxParticipants: 72,
    entryFeeDisplay: "$75.00",
    holes: 18,
    registrationAvailable: false,
  },
};

export const Free: Story = {
  args: {
    id: "6",
    name: "Beginner's Fun Day",
    format: "SCRAMBLE",
    status: "REGISTRATION_OPEN",
    startDate: "2026-04-01",
    endDate: "2026-04-01",
    courseName: "Municipal Links",
    entriesCount: 12,
    maxParticipants: null,
    entryFeeDisplay: "$0.00",
    holes: 9,
    registrationAvailable: true,
  },
};

export const Draft: Story = {
  args: {
    id: "7",
    name: "Fall Invitational (Draft)",
    format: "STROKE",
    status: "DRAFT",
    startDate: "2026-10-01",
    endDate: "2026-10-01",
    courseName: "Shadow Creek",
    entriesCount: 0,
    maxParticipants: 36,
    entryFeeDisplay: "$200.00",
    holes: 18,
    registrationAvailable: false,
  },
};
