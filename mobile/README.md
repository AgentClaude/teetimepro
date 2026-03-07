# TeeTimes Pro Mobile App

Expo React Native mobile app for golfers to search, book, and manage tee times.

## Tech Stack

- **Expo SDK 55** with React Native 0.83
- **TypeScript** (strict mode)
- **React Navigation** (native stack + bottom tabs)
- **Apollo Client v4** for GraphQL
- **expo-secure-store** for auth token storage
- **Zod + React Hook Form** for validation
- **NativeWind** (TailwindCSS for React Native)

## Project Structure

```
mobile/
├── src/
│   ├── components/ui/     # Shared UI components (Button, Input, etc.)
│   ├── config/            # Environment configuration
│   ├── graphql/           # Apollo client, queries, mutations, codegen
│   ├── hooks/             # Custom hooks (useAuth, etc.)
│   ├── navigation/        # React Navigation setup
│   ├── screens/           # Screen components by feature
│   │   ├── auth/          # Login, Register, ForgotPassword
│   │   ├── booking/       # Tee time search and booking
│   │   ├── home/          # Home dashboard
│   │   └── profile/       # User profile and settings
│   ├── services/          # Auth storage, API helpers
│   ├── types/             # TypeScript type definitions
│   └── utils/             # Utility functions
├── App.tsx                # Root component
├── app.json               # Expo configuration
├── codegen.ts             # GraphQL code generation config
└── babel.config.js        # Babel config with path aliases
```

## Getting Started

```bash
cd mobile
npm install
npm start
```

## Development

```bash
# Type checking
npm run typecheck

# Generate GraphQL types (requires API running)
npm run codegen

# Run on iOS simulator
npm run ios

# Run on Android emulator
npm run android
```

## Path Aliases

Use `@/` to import from `src/`:

```typescript
import { Button } from '@/components/ui';
import { useAuth } from '@/hooks/useAuth';
```
