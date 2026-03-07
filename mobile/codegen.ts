import type { CodegenConfig } from '@graphql-codegen/cli';

const config: CodegenConfig = {
  schema: 'http://localhost:3000/graphql',
  documents: ['src/**/*.tsx', 'src/**/*.ts'],
  generates: {
    './src/graphql/__generated__/': {
      preset: 'client',
      config: {
        documentMode: 'string',
      },
    },
  },
  ignoreNoDocuments: true,
};

export default config;
