---
name: react-expert
description: Expert React development with TypeScript, hooks, TailwindCSS, Apollo Client, and modern patterns. Use for React component design, state management, GraphQL integration, performance optimization, accessibility, or code review of React/TypeScript code. Triggers on React, TypeScript, hooks, Tailwind, Apollo, frontend, or component architecture.
---

# React Expert

## Architecture

### Component Patterns
- **Functional components only** (no class components)
- **Custom hooks** for all shared logic (`useAuth`, `useTransactions`, `useDebounce`)
- **Composition over prop drilling** — use context for cross-cutting concerns
- **Colocation** — keep styles, tests, types near components

### File Structure
```
src/
├── components/     # Reusable UI components
├── pages/          # Route-level components
├── hooks/          # Custom hooks
├── graphql/        # Queries, mutations, fragments
├── lib/            # Utilities, Apollo client, helpers
├── types/          # Shared TypeScript interfaces
└── generated/      # GraphQL codegen output (don't edit)
```

### TypeScript
- **Strict mode** always
- **Interface over type** for objects (extendable)
- **No `any`** — use `unknown` and narrow
- **GraphQL Codegen** for API types — never hand-write query types

### State Management
- **Local state**: `useState` for component state
- **Server state**: Apollo Client cache (or React Query)
- **Global state**: React Context for auth, theme, preferences
- **URL state**: React Router for filters, pagination, tabs

### Apollo Client / GraphQL Layer
- `fetchPolicy: 'network-only'` for data that changes often
- `cache.modify` for optimistic updates
- Never use broken merge policies on paginated queries
- Strip empty/null values from variables before sending

#### GraphQL Architecture (MANDATORY)
```
graphql/queries.ts + mutations.ts  →  hooks/use*.ts  →  pages/*.tsx
      (GQL documents)                 (typed hooks)     (UI only)
```

**Rules:**
1. **All `gql` documents** live in `graphql/queries.ts` or `graphql/mutations.ts` — never inline in components
2. **All `useQuery`/`useMutation` calls** live in custom hooks under `hooks/` — never in page components
3. **Pages only import hooks** — zero direct `@apollo/client` imports in `pages/`
4. **Hooks export typed interfaces** — callers never deal with raw GraphQL response shapes
5. **Barrel export** at `hooks/index.ts` for clean imports
6. **Shared types** exported from hooks so pages don't re-declare interfaces

**Why:** Reusability (multiple pages can share the same hook), testability (mock the hook, not Apollo), type safety (hook defines the contract), and separation of concerns (pages = UI, hooks = data).

## Patterns

### Custom Hook Pattern
```typescript
// hooks/useTransactions.ts
import { useQuery, useMutation } from '@apollo/client';
import { GET_TRANSACTIONS } from '@/graphql/queries';
import { CREATE_TRANSACTION } from '@/graphql/mutations';

export const useTransactions = (filters: Filters = {}) => {
  const cleaned = cleanFilters(filters);
  const { data, loading, refetch } = useQuery(GET_TRANSACTIONS, {
    variables: cleaned,
  });

  const [createMutation, { loading: creating }] = useMutation(CREATE_TRANSACTION, {
    refetchQueries: [{ query: GET_TRANSACTIONS }],
  });

  const createTransaction = async (input: CreateInput) => {
    const result = await createMutation({ variables: { input } });
    return result.data.createTransaction;
  };

  return {
    transactions: data?.transactions ?? [],
    loading,
    creating,
    refetch,
    createTransaction,
  };
};

// pages/TransactionsPage.tsx — clean, no Apollo imports
import { useTransactions } from '@/hooks/useTransactions';

const TransactionsPage = () => {
  const { transactions, loading, createTransaction } = useTransactions(filters);
  // ... UI only
};
```

### Hook per Domain
One hook per domain entity. Each hook encapsulates:
- Queries (data fetching)
- Mutations (create/update/delete)
- Derived data (computed values, filters)
- Loading/error states

| Domain | Hook | Responsibilities |
|--------|------|-----------------|
| Accounts | `useAccounts` | CRUD, Plaid link, balance calculations |
| Transactions | `useTransactions` | CRUD, filtering, pagination, bulk ops |
| Categories | `useCategories` | CRUD, grouping, subcategories |
| Budget | `useBudget` | Month navigation, budget items, copy/fill |
| Rules | `useRules` | CRUD, apply rules |
| Recurring | `useRecurring` | List, detect, income/expense splits |
| Reports | `useReports` | Fetch with date range, summary helpers |
| Settings | `useSettings` | Profile update, password change |
```

### Error Boundary
Wrap route-level components. Show fallback UI, report to logging.

### Loading States
Skeleton screens > spinners. Show layout shape while loading.

## Code Review Checklist
See references/react-review-checklist.md

## Performance
See references/react-performance.md
