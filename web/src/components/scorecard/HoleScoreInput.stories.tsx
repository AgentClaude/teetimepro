import type { Meta, StoryObj } from '@storybook/react';
import { useState } from 'react';
import { HoleScoreInput } from './HoleScoreInput';
import type { HoleScore } from '../../types/scorecard';

const meta: Meta<typeof HoleScoreInput> = {
  title: 'Scorecard/HoleScoreInput',
  component: HoleScoreInput,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof HoleScoreInput>;

function mockHoleScore(overrides: Partial<HoleScore> = {}): HoleScore {
  return {
    id: '1',
    holeNumber: 1,
    par: 4,
    strokes: null,
    putts: null,
    fairwayHit: null,
    greenInRegulation: null,
    penalties: null,
    scoreToPar: null,
    notes: null,
    ...overrides,
  };
}

function InteractiveWrapper({ initial }: { initial: HoleScore }) {
  const [score, setScore] = useState(initial);
  const [active, setActive] = useState(false);

  return (
    <div className="w-20">
      <HoleScoreInput
        holeScore={score}
        isActive={active}
        onUpdate={(_hole, data) => setScore((prev) => ({ ...prev, ...data }))}
        onSelect={() => setActive(true)}
      />
    </div>
  );
}

export const Unscored: Story = {
  render: () => <InteractiveWrapper initial={mockHoleScore()} />,
};

export const Par: Story = {
  render: () => <InteractiveWrapper initial={mockHoleScore({ strokes: 4, scoreToPar: 0 })} />,
};

export const Birdie: Story = {
  render: () => <InteractiveWrapper initial={mockHoleScore({ strokes: 3, scoreToPar: -1 })} />,
};

export const Eagle: Story = {
  render: () => <InteractiveWrapper initial={mockHoleScore({ par: 5, strokes: 3, scoreToPar: -2 })} />,
};

export const Bogey: Story = {
  render: () => <InteractiveWrapper initial={mockHoleScore({ strokes: 5, scoreToPar: 1 })} />,
};

export const DoubleBogey: Story = {
  render: () => <InteractiveWrapper initial={mockHoleScore({ strokes: 6, scoreToPar: 2 })} />,
};

export const Par3Hole: Story = {
  render: () => (
    <InteractiveWrapper initial={mockHoleScore({ holeNumber: 7, par: 3 })} />
  ),
};

export const Par5Hole: Story = {
  render: () => (
    <InteractiveWrapper initial={mockHoleScore({ holeNumber: 5, par: 5 })} />
  ),
};

export const Disabled: Story = {
  render: () => (
    <div className="w-20">
      <HoleScoreInput
        holeScore={mockHoleScore({ strokes: 4, scoreToPar: 0 })}
        isActive={false}
        onUpdate={() => {}}
        onSelect={() => {}}
        disabled
      />
    </div>
  ),
};
