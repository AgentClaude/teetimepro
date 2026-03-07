import type { Meta, StoryObj } from '@storybook/react';
import { useState } from 'react';
import { CustomerPagination } from './CustomerPagination';

const meta: Meta<typeof CustomerPagination> = {
  title: 'Customers/CustomerPagination',
  component: CustomerPagination,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof CustomerPagination>;

function PaginationWrapper(props: { totalPages: number; totalCount: number; perPage?: number; startPage?: number }) {
  const [page, setPage] = useState(props.startPage ?? 1);
  return (
    <CustomerPagination
      page={page}
      totalPages={props.totalPages}
      totalCount={props.totalCount}
      perPage={props.perPage ?? 25}
      onPageChange={setPage}
    />
  );
}

export const FirstPage: Story = {
  render: () => <PaginationWrapper totalPages={10} totalCount={247} />,
};

export const MiddlePage: Story = {
  render: () => <PaginationWrapper totalPages={10} totalCount={247} startPage={5} />,
};

export const LastPage: Story = {
  render: () => <PaginationWrapper totalPages={10} totalCount={247} startPage={10} />,
};

export const FewPages: Story = {
  render: () => <PaginationWrapper totalPages={3} totalCount={65} />,
};

export const SinglePage: Story = {
  render: () => <PaginationWrapper totalPages={1} totalCount={15} />,
};
