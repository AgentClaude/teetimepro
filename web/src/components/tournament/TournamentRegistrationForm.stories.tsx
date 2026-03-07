import type { Meta, StoryObj } from "@storybook/react";
import { TournamentRegistrationForm } from "./TournamentRegistrationForm";

const meta: Meta<typeof TournamentRegistrationForm> = {
  title: "Tournament/TournamentRegistrationForm",
  component: TournamentRegistrationForm,
  parameters: {
    layout: "centered",
    docs: {
      description: {
        component: "A comprehensive tournament registration form with payment integration for paid tournaments."
      }
    }
  },
  args: {
    isOpen: true,
    onClose: () => {},
    onSuccess: () => {},
  },
};

export default meta;
type Story = StoryObj<typeof TournamentRegistrationForm>;

const baseTournament = {
  id: "tournament-1",
  name: "Spring Classic 2026",
  format: "STROKE" as const,
  teamSize: 1,
  maxParticipants: 72,
  entriesCount: 45,
};

export const FreeTournament: Story = {
  args: {
    tournament: {
      ...baseTournament,
      entryFeeCents: 0,
      entryFeeDisplay: "$0.00",
      handicapEnabled: false,
    },
  },
  parameters: {
    docs: {
      description: {
        story: "Registration form for a free tournament with no handicap requirement."
      }
    }
  }
};

export const PaidTournament: Story = {
  args: {
    tournament: {
      ...baseTournament,
      entryFeeCents: 5000, // $50.00
      entryFeeDisplay: "$50.00",
      handicapEnabled: false,
    },
  },
  parameters: {
    docs: {
      description: {
        story: "Registration form for a paid tournament that requires payment processing."
      }
    }
  }
};

export const HandicapRequired: Story = {
  args: {
    tournament: {
      ...baseTournament,
      entryFeeCents: 7500, // $75.00
      entryFeeDisplay: "$75.00",
      handicapEnabled: true,
      maxHandicap: 18.0,
    },
  },
  parameters: {
    docs: {
      description: {
        story: "Registration form requiring a handicap index with a maximum limit."
      }
    }
  }
};

export const ScrambleWithTeam: Story = {
  args: {
    tournament: {
      ...baseTournament,
      name: "Charity Scramble",
      format: "SCRAMBLE" as const,
      teamSize: 4,
      entryFeeCents: 10000, // $100.00
      entryFeeDisplay: "$100.00",
      handicapEnabled: true,
      maxHandicap: 25.0,
    },
  },
  parameters: {
    docs: {
      description: {
        story: "Registration form for a team scramble requiring both team name and handicaps."
      }
    }
  }
};

export const FullTournament: Story = {
  args: {
    tournament: {
      ...baseTournament,
      entryFeeCents: 12500, // $125.00
      entryFeeDisplay: "$125.00",
      handicapEnabled: true,
      maxHandicap: 20.0,
      maxParticipants: 72,
      entriesCount: 72, // Full tournament
    },
  },
  parameters: {
    docs: {
      description: {
        story: "Registration form for a full tournament where users will be waitlisted."
      }
    }
  }
};

export const BestBallPartnership: Story = {
  args: {
    tournament: {
      ...baseTournament,
      name: "Member-Guest Championship",
      format: "BEST_BALL" as const,
      teamSize: 2,
      entryFeeCents: 15000, // $150.00
      entryFeeDisplay: "$150.00",
      handicapEnabled: true,
      maxHandicap: 30.0,
    },
  },
  parameters: {
    docs: {
      description: {
        story: "Registration form for a best ball tournament with 2-person teams."
      }
    }
  }
};

export const HighStakesTournament: Story = {
  args: {
    tournament: {
      ...baseTournament,
      name: "Championship Flight",
      entryFeeCents: 25000, // $250.00
      entryFeeDisplay: "$250.00",
      handicapEnabled: true,
      maxHandicap: 5.0, // Very low handicap limit
      maxParticipants: 32,
      entriesCount: 28,
    },
  },
  parameters: {
    docs: {
      description: {
        story: "High-stakes tournament with strict handicap limits and premium entry fee."
      }
    }
  }
};

export const Closed: Story = {
  args: {
    isOpen: false,
    tournament: {
      ...baseTournament,
      entryFeeCents: 5000,
      entryFeeDisplay: "$50.00",
      handicapEnabled: false,
    },
  },
  parameters: {
    docs: {
      description: {
        story: "Modal in closed state - useful for testing interactions."
      }
    }
  }
};