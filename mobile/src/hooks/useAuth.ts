import { useState, useEffect, useCallback, createContext, useContext } from 'react';
import { authStorage } from '@/services/auth';

interface AuthState {
  isAuthenticated: boolean;
  isLoading: boolean;
  token: string | null;
}

interface AuthContextType extends AuthState {
  signIn: (token: string, refreshToken?: string) => Promise<void>;
  signOut: () => Promise<void>;
}

const initialState: AuthState = {
  isAuthenticated: false,
  isLoading: true,
  token: null,
};

export const AuthContext = createContext<AuthContextType>({
  ...initialState,
  signIn: async () => {},
  signOut: async () => {},
});

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const useAuthState = (): {
  state: AuthState;
  signIn: (token: string, refreshToken?: string) => Promise<void>;
  signOut: () => Promise<void>;
} => {
  const [state, setState] = useState<AuthState>(initialState);

  useEffect(() => {
    const checkAuth = async () => {
      try {
        const token = await authStorage.getToken();
        setState({
          isAuthenticated: token !== null,
          isLoading: false,
          token,
        });
      } catch {
        setState({
          isAuthenticated: false,
          isLoading: false,
          token: null,
        });
      }
    };
    void checkAuth();
  }, []);

  const signIn = useCallback(async (token: string, refreshToken?: string) => {
    await authStorage.setToken(token);
    if (refreshToken) {
      await authStorage.setRefreshToken(refreshToken);
    }
    setState({ isAuthenticated: true, isLoading: false, token });
  }, []);

  const signOut = useCallback(async () => {
    await authStorage.clearTokens();
    setState({ isAuthenticated: false, isLoading: false, token: null });
  }, []);

  return { state, signIn, signOut };
};
