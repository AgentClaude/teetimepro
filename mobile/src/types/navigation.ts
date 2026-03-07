import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import type { BottomTabScreenProps } from '@react-navigation/bottom-tabs';
import type { CompositeScreenProps, NavigatorScreenParams } from '@react-navigation/native';

// Auth stack
export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
};

// Booking stack (nested inside BookTab)
export type BookingStackParamList = {
  CourseSearch: undefined;
  TeeTimeSelect: {
    courseSlug: string;
    courseName: string;
  };
  BookingConfirm: {
    courseSlug: string;
    courseName: string;
    teeTimeId: string;
    formattedTime: string;
    startsAt: string;
    priceCents: number | null;
    dynamicPriceCents: number | null;
    availableSpots: number;
  };
  BookingSuccess: {
    confirmationCode: string;
    courseName: string;
    formattedTime: string;
    startsAt: string;
    playersCount: number;
    totalCents: number;
  };
};

// Main tab navigator
export type MainTabParamList = {
  HomeTab: undefined;
  BookTab: NavigatorScreenParams<BookingStackParamList>;
  ProfileTab: undefined;
};

// Root stack (wraps auth + main)
export type RootStackParamList = {
  Auth: NavigatorScreenParams<AuthStackParamList>;
  Main: NavigatorScreenParams<MainTabParamList>;
};

// Screen props helpers
export type AuthScreenProps<T extends keyof AuthStackParamList> =
  NativeStackScreenProps<AuthStackParamList, T>;

export type BookingScreenProps<T extends keyof BookingStackParamList> =
  CompositeScreenProps<
    NativeStackScreenProps<BookingStackParamList, T>,
    CompositeScreenProps<
      BottomTabScreenProps<MainTabParamList>,
      NativeStackScreenProps<RootStackParamList>
    >
  >;

export type MainTabScreenProps<T extends keyof MainTabParamList> =
  CompositeScreenProps<
    BottomTabScreenProps<MainTabParamList, T>,
    NativeStackScreenProps<RootStackParamList>
  >;

declare global {
  namespace ReactNavigation {
    interface RootParamList extends RootStackParamList {}
  }
}
