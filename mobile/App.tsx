import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { ApolloProvider } from '@apollo/client/react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { apolloClient } from '@/graphql/client';
import { AuthContext, useAuthState } from '@/hooks/useAuth';
import { RootNavigator } from '@/navigation/RootNavigator';

export default function App() {
  const { state, signIn, signOut } = useAuthState();

  return (
    <SafeAreaProvider>
      <ApolloProvider client={apolloClient}>
        <AuthContext.Provider value={{ ...state, signIn, signOut }}>
          <RootNavigator />
          <StatusBar style="auto" />
        </AuthContext.Provider>
      </ApolloProvider>
    </SafeAreaProvider>
  );
}
