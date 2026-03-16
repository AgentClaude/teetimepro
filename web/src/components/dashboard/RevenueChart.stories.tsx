import type { Meta, StoryObj } from '@storybook/react';
import { RevenueChart } from './RevenueChart';

interface RevenueData {
  date: string;
  revenueCents: number;
}

function generateMockRevenueData(days: number): RevenueData[] {
  const data: RevenueData[] = [];
  const today = new Date();
  
  for (let i = days - 1; i >= 0; i--) {
    const date = new Date(today.getTime() - i * 24 * 60 * 60 * 1000);
    const dateString = date.toISOString().split('T')[0];
    
    // Generate realistic revenue data with some variation
    const baseRevenue = 250000; // $2,500 base
    const variation = Math.random() * 150000; // Up to $1,500 variation
    const dayOfWeek = date.getDay();
    
    // Weekend multiplier
    const weekendMultiplier = dayOfWeek === 0 || dayOfWeek === 6 ? 1.4 : 1.0;
    
    data.push({
      date: dateString,
      revenueCents: Math.round((baseRevenue + variation) * weekendMultiplier),
    });
  }
  
  return data;
}

const meta = {
  title: 'Components/Dashboard/RevenueChart',
  component: RevenueChart,
  parameters: {
    layout: 'padded',
  },
  tags: ['autodocs'],
} satisfies Meta<typeof RevenueChart>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    data: generateMockRevenueData(7),
    loading: false,
  },
};

export const Loading: Story = {
  args: {
    data: [],
    loading: true,
  },
};

export const Empty: Story = {
  args: {
    data: [],
    loading: false,
  },
};

export const SingleDay: Story = {
  args: {
    data: generateMockRevenueData(1),
    loading: false,
  },
};

export const LowRevenue: Story = {
  args: {
    data: [
      { date: '2024-01-01', revenueCents: 50000 }, // $500
      { date: '2024-01-02', revenueCents: 75000 }, // $750
      { date: '2024-01-03', revenueCents: 60000 }, // $600
      { date: '2024-01-04', revenueCents: 85000 }, // $850
      { date: '2024-01-05', revenueCents: 70000 }, // $700
      { date: '2024-01-06', revenueCents: 90000 }, // $900
      { date: '2024-01-07', revenueCents: 80000 }, // $800
    ],
    loading: false,
  },
};

export const HighRevenue: Story = {
  args: {
    data: [
      { date: '2024-01-01', revenueCents: 500000 }, // $5,000
      { date: '2024-01-02', revenueCents: 750000 }, // $7,500
      { date: '2024-01-03', revenueCents: 600000 }, // $6,000
      { date: '2024-01-04', revenueCents: 850000 }, // $8,500
      { date: '2024-01-05', revenueCents: 700000 }, // $7,000
      { date: '2024-01-06', revenueCents: 900000 }, // $9,000
      { date: '2024-01-07', revenueCents: 800000 }, // $8,000
    ],
    loading: false,
  },
};

export const VolatileRevenue: Story = {
  args: {
    data: [
      { date: '2024-01-01', revenueCents: 100000 }, // $1,000
      { date: '2024-01-02', revenueCents: 800000 }, // $8,000
      { date: '2024-01-03', revenueCents: 200000 }, // $2,000
      { date: '2024-01-04', revenueCents: 950000 }, // $9,500
      { date: '2024-01-05', revenueCents: 150000 }, // $1,500
      { date: '2024-01-06', revenueCents: 700000 }, // $7,000
      { date: '2024-01-07', revenueCents: 300000 }, // $3,000
    ],
    loading: false,
  },
};