import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { CourseSearchScreen } from '@/screens/booking/CourseSearchScreen';
import { TeeTimeSelectScreen } from '@/screens/booking/TeeTimeSelectScreen';
import { BookingConfirmScreen } from '@/screens/booking/BookingConfirmScreen';
import { BookingSuccessScreen } from '@/screens/booking/BookingSuccessScreen';
import type { BookingStackParamList } from '@/types/navigation';

const Stack = createNativeStackNavigator<BookingStackParamList>();

export const BookingNavigator: React.FC = () => {
  return (
    <Stack.Navigator
      screenOptions={{
        headerStyle: { backgroundColor: '#ffffff' },
        headerTintColor: '#1f2937',
        headerShadowVisible: false,
        headerBackTitle: '',
      }}
    >
      <Stack.Screen
        name="CourseSearch"
        component={CourseSearchScreen}
        options={{ title: 'Find a Course' }}
      />
      <Stack.Screen
        name="TeeTimeSelect"
        component={TeeTimeSelectScreen}
        options={({ route }) => ({ title: route.params.courseName })}
      />
      <Stack.Screen
        name="BookingConfirm"
        component={BookingConfirmScreen}
        options={{ title: 'Confirm Booking' }}
      />
      <Stack.Screen
        name="BookingSuccess"
        component={BookingSuccessScreen}
        options={{ title: '', headerBackVisible: false, gestureEnabled: false }}
      />
    </Stack.Navigator>
  );
};
