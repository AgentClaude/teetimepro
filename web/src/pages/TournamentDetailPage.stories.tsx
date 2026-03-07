import type { Meta, StoryObj } from "@storybook/react";
import { BrowserRouter } from "react-router-dom";
import { MockedProvider } from "@apollo/client/testing";
import { TournamentDetailPage } from "./TournamentDetailPage";
import { GET_TOURNAMENT } from "../graphql/queries";

const meta: Meta<typeof TournamentDetailPage> = {
  title: "Pages/TournamentDetailPage",
  component: TournamentDetailPage,
  parameters: {
    layout: "fullscreen",
    docs: {
      description: {
        component: "Complete tournament detail page showing all tournament information, participant list, and registration/withdrawal actions."
      }
    }
  },
  decorators: [
    (Story: React.ComponentType) => (
      <BrowserRouter>
        <div className="min-h-screen bg-gray-50 p-4">
          <Story />
        </div>
      </BrowserRouter>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof TournamentDetailPage>;

interface MockTournament {
  id: string;
  name: string;
  description: string;
  format: string;
  status: string;
  startDate: string;
  endDate: string;
  holes: number;
  teamSize: number;
  maxParticipants?: number;
  minParticipants: number;
  entriesCount: number;
  registrationAvailable: boolean;
  entryFeeCents: number;
  entryFeeDisplay: string;
  handicapEnabled: boolean;
  maxHandicap?: number;
  rules?: string;
  prizeStructure?: string;
  registrationOpensAt?: string;
  registrationClosesAt?: string;
  days: number;
  course: {
    id: string;
    name: string;
  };
  createdBy: {
    id: string;
    fullName: string;
  };
  tournamentEntries: Array<{
    id: string;
    status: string;
    teamName?: string;
    handicapIndex?: number;
    user: {
      id: string;
      fullName: string;
      email: string;
    };
  }>;
}

const baseTournament: Omit<MockTournament, 'tournamentEntries'> = {
  id: "tournament-1",
  name: "Spring Classic 2026",
  description: "Join us for our annual spring tournament featuring 18 holes of competitive stroke play on our championship course.",
  format: "STROKE",
  status: "REGISTRATION_OPEN",
  startDate: "2026-04-15",
  endDate: "2026-04-15",
  holes: 18,
  teamSize: 1,
  maxParticipants: 72 as number | undefined,
  minParticipants: 8,
  entriesCount: 34,
  registrationAvailable: true,
  entryFeeCents: 5000,
  entryFeeDisplay: "$50.00",
  handicapEnabled: true,
  maxHandicap: 18.0,
  rules: "• All participants must have a valid USGA handicap\n• Proper golf attire required\n• No metal spikes\n• Cart rental available for additional fee\n• Rain or shine event",
  prizeStructure: "1st Place: $500 + Trophy\n2nd Place: $300\n3rd Place: $200\nClosest to Pin: $100\nLongest Drive: $100",
  registrationOpensAt: "2026-03-01T00:00:00Z",
  registrationClosesAt: "2026-04-10T23:59:59Z",
  days: 1,
  course: {
    id: "course-1",
    name: "Pine Valley Golf Course",
  },
  createdBy: {
    id: "user-1",
    fullName: "John Smith",
  },
};

const generateMockEntries = (count: number) => {
  return Array.from({ length: count }, (_, i) => ({
    id: `entry-${i + 1}`,
    status: "CONFIRMED",
    teamName: i % 3 === 0 ? `Team ${i + 1}` : undefined,
    handicapIndex: Math.round((Math.random() * 15 + 2) * 10) / 10,
    user: {
      id: `user-${i + 1}`,
      fullName: `Player ${i + 1}`,
      email: `player${i + 1}@example.com`,
    },
  }));
};



const createMockQuery = (tournament: MockTournament) => ({
  request: {
    query: GET_TOURNAMENT,
    variables: { id: "tournament-1" },
  },
  result: {
    data: {
      tournament,
    },
  },
});

export const RegistrationOpen: Story = {
  decorators: [
    (Story: React.ComponentType) => (
      <MockedProvider 
        mocks={[createMockQuery({
          ...baseTournament,
          tournamentEntries: generateMockEntries(34),
        })]} 
        addTypename={false}
      >
        <BrowserRouter>
          <div className="min-h-screen bg-gray-50 p-4">
            <Story />
          </div>
        </BrowserRouter>
      </MockedProvider>
    ),
  ],
  parameters: {
    docs: {
      description: {
        story: "Tournament with registration open and available spots."
      }
    }
  }
};

export const FreeTournament: Story = {
  decorators: [
    (Story: React.ComponentType) => (
      <MockedProvider 
        mocks={[createMockQuery({
          ...baseTournament,
          name: "Beginner's Fun Day",
          entryFeeCents: 0,
          entryFeeDisplay: "$0.00",
          handicapEnabled: false,
          holes: 9,
          maxParticipants: 999,
          entriesCount: 12,
          tournamentEntries: generateMockEntries(12),
        })]} 
        addTypename={false}
      >
        <BrowserRouter>
          <div className="min-h-screen bg-gray-50 p-4">
            <Story />
          </div>
        </BrowserRouter>
      </MockedProvider>
    ),
  ],
  parameters: {
    docs: {
      description: {
        story: "Free tournament with no entry fee and no participant limit."
      }
    }
  }
};

export const ScrambleWithTeams: Story = {
  decorators: [
    (Story: React.ComponentType) => (
      <MockedProvider 
        mocks={[createMockQuery({
          ...baseTournament,
          name: "Charity Scramble",
          format: "SCRAMBLE",
          teamSize: 4,
          entryFeeCents: 10000,
          entryFeeDisplay: "$100.00",
          entriesCount: 48,
          tournamentEntries: generateMockEntries(48).map((entry, i) => ({
            ...entry,
            teamName: `Team ${Math.floor(i / 4) + 1}`,
          })),
        })]} 
        addTypename={false}
      >
        <BrowserRouter>
          <div className="min-h-screen bg-gray-50 p-4">
            <Story />
          </div>
        </BrowserRouter>
      </MockedProvider>
    ),
  ],
  parameters: {
    docs: {
      description: {
        story: "Team scramble tournament showing team names and multiple participants."
      }
    }
  }
};

export const FullTournamentWithWaitlist: Story = {
  decorators: [
    (Story: React.ComponentType) => (
      <MockedProvider 
        mocks={[createMockQuery({
          ...baseTournament,
          entriesCount: 76, // More than max participants
          tournamentEntries: [
            ...generateMockEntries(72),
            ...generateMockEntries(4).map((entry, i) => ({
              ...entry,
              id: `waitlist-${i + 1}`,
              status: "WAITLISTED",
            })),
          ],
        })]} 
        addTypename={false}
      >
        <BrowserRouter>
          <div className="min-h-screen bg-gray-50 p-4">
            <Story />
          </div>
        </BrowserRouter>
      </MockedProvider>
    ),
  ],
  parameters: {
    docs: {
      description: {
        story: "Full tournament showing both confirmed participants and waitlist."
      }
    }
  }
};

export const InProgress: Story = {
  decorators: [
    (Story: React.ComponentType) => (
      <MockedProvider 
        mocks={[createMockQuery({
          ...baseTournament,
          status: "IN_PROGRESS",
          registrationAvailable: false,
          startDate: "2026-03-06",
          endDate: "2026-03-06",
          entriesCount: 64,
          tournamentEntries: generateMockEntries(64),
        })]} 
        addTypename={false}
      >
        <BrowserRouter>
          <div className="min-h-screen bg-gray-50 p-4">
            <Story />
          </div>
        </BrowserRouter>
      </MockedProvider>
    ),
  ],
  parameters: {
    docs: {
      description: {
        story: "Tournament currently in progress with registration closed."
      }
    }
  }
};

export const Completed: Story = {
  decorators: [
    (Story: React.ComponentType) => (
      <MockedProvider 
        mocks={[createMockQuery({
          ...baseTournament,
          status: "COMPLETED",
          registrationAvailable: false,
          startDate: "2026-02-15",
          endDate: "2026-02-15",
          entriesCount: 56,
          tournamentEntries: generateMockEntries(56),
        })]} 
        addTypename={false}
      >
        <BrowserRouter>
          <div className="min-h-screen bg-gray-50 p-4">
            <Story />
          </div>
        </BrowserRouter>
      </MockedProvider>
    ),
  ],
  parameters: {
    docs: {
      description: {
        story: "Completed tournament showing final participant list."
      }
    }
  }
};

export const MultiDayChampionship: Story = {
  decorators: [
    (Story: React.ComponentType) => (
      <MockedProvider 
        mocks={[createMockQuery({
          ...baseTournament,
          name: "Summer Championship",
          format: "MATCH_PLAY",
          startDate: "2026-06-10",
          endDate: "2026-06-12",
          days: 3,
          entryFeeCents: 25000,
          entryFeeDisplay: "$250.00",
          maxParticipants: 64,
          entriesCount: 64,
          maxHandicap: 8.0,
          rules: "• Match play format over 3 days\n• All participants must have handicap ≤ 8.0\n• Qualifying round on Day 1\n• Elimination rounds Days 2-3\n• All meals included in entry fee",
          prizeStructure: "Champion: $2,000 + Trophy\nRunner-up: $1,000\nSemi-finalists: $500 each\nQuarter-finalists: $250 each",
          tournamentEntries: generateMockEntries(64),
        })]} 
        addTypename={false}
      >
        <BrowserRouter>
          <div className="min-h-screen bg-gray-50 p-4">
            <Story />
          </div>
        </BrowserRouter>
      </MockedProvider>
    ),
  ],
  parameters: {
    docs: {
      description: {
        story: "Multi-day championship tournament with detailed rules and prize structure."
      }
    }
  }
};

export const EmptyTournament: Story = {
  decorators: [
    (Story: React.ComponentType) => (
      <MockedProvider 
        mocks={[createMockQuery({
          ...baseTournament,
          entriesCount: 0,
          tournamentEntries: [],
        })]} 
        addTypename={false}
      >
        <BrowserRouter>
          <div className="min-h-screen bg-gray-50 p-4">
            <Story />
          </div>
        </BrowserRouter>
      </MockedProvider>
    ),
  ],
  parameters: {
    docs: {
      description: {
        story: "Tournament with no participants yet - shows empty state."
      }
    }
  }
};

export const Loading: Story = {
  decorators: [
    (Story: React.ComponentType) => (
      <MockedProvider mocks={[]} addTypename={false}>
        <BrowserRouter>
          <div className="min-h-screen bg-gray-50 p-4">
            <Story />
          </div>
        </BrowserRouter>
      </MockedProvider>
    ),
  ],
  parameters: {
    docs: {
      description: {
        story: "Loading state while tournament data is being fetched."
      }
    }
  }
};