import Constants from 'expo-constants';

interface AppConfig {
  apiUrl: string;
  graphqlUrl: string;
  environment: 'development' | 'staging' | 'production';
}

const getConfig = (): AppConfig => {
  const extra = Constants.expoConfig?.extra;

  return {
    apiUrl: (extra?.apiUrl as string) ?? 'http://localhost:3000',
    graphqlUrl: (extra?.graphqlUrl as string) ?? 'http://localhost:3000/graphql',
    environment: (extra?.environment as AppConfig['environment']) ?? 'development',
  };
};

export const config = getConfig();
