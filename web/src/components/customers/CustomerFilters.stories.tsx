import type { Meta, StoryObj } from '@storybook/react';
import { useState } from 'react';
import { CustomerFilters, CustomerFilterValues, INITIAL_FILTERS } from './CustomerFilters';

const meta: Meta<typeof CustomerFilters> = {
  title: 'Customers/CustomerFilters',
  component: CustomerFilters,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof CustomerFilters>;

function CustomerFiltersWrapper(props: { initialFilters?: Partial<CustomerFilterValues>; totalCount?: number }) {
  const [filters, setFilters] = useState<CustomerFilterValues>({
    ...INITIAL_FILTERS,
    ...props.initialFilters,
  });
  return <CustomerFilters filters={filters} onChange={setFilters} totalCount={props.totalCount} />;
}

export const Default: Story = {
  render: () => <CustomerFiltersWrapper totalCount={247} />,
};

export const WithSearch: Story = {
  render: () => (
    <CustomerFiltersWrapper
      initialFilters={{ search: 'john smith' }}
      totalCount={3}
    />
  ),
};

export const WithActiveFilters: Story = {
  render: () => (
    <CustomerFiltersWrapper
      initialFilters={{
        role: 'golfer',
        membershipTier: 'gold',
        loyaltyTier: 'silver',
        minBookings: '5',
      }}
      totalCount={12}
    />
  ),
};

export const SortedByName: Story = {
  render: () => (
    <CustomerFiltersWrapper
      initialFilters={{ sortBy: 'name', sortDir: 'asc' }}
      totalCount={247}
    />
  ),
};

export const NoResults: Story = {
  render: () => (
    <CustomerFiltersWrapper
      initialFilters={{ search: 'nonexistent', role: 'golfer' }}
      totalCount={0}
    />
  ),
};
