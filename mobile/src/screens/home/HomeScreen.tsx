import React, { useCallback } from 'react';
import { View, Text, StyleSheet, ScrollView, RefreshControl } from 'react-native';
import { useQuery } from '@apollo/client/react';
import { useNavigation } from '@react-navigation/native';
import type { BottomTabNavigationProp } from '@react-navigation/bottom-tabs';
import { Button } from '@/components/ui';
import { useAuth } from '@/hooks/useAuth';
import { MY_BOOKINGS_QUERY } from '@/graphql/operations/booking';
import { formatDate } from '@/utils/format';
import type { Booking } from '@/types/booking';
import type { MainTabParamList } from '@/types/navigation';

interface BookingsQueryResult {
  bookings: Booking[];
}

export const HomeScreen: React.FC = () => {
  const { signOut, isAuthenticated } = useAuth();
  const navigation = useNavigation<BottomTabNavigationProp<MainTabParamList>>();

  const { data, loading, refetch } = useQuery<BookingsQueryResult>(MY_BOOKINGS_QUERY, {
    variables: { status: 'confirmed' },
    skip: !isAuthenticated,
    fetchPolicy: 'cache-and-network',
  });

  const bookings = data?.bookings;
  const upcomingBookings = (bookings ?? []).filter((b) => {
    return new Date(b.teeTime.startsAt) > new Date();
  });

  const handleSearchTeeTimes = useCallback(() => {
    navigation.navigate('BookTab', { screen: 'CourseSearch' });
  }, [navigation]);

  const getGreeting = (): string => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning! ⛳';
    if (hour < 17) return 'Good afternoon! ⛳';
    return 'Good evening! ⛳';
  };

  return (
    <ScrollView
      style={styles.container}
      contentContainerStyle={styles.content}
      refreshControl={
        <RefreshControl refreshing={loading} onRefresh={() => void refetch()} tintColor="#16a34a" />
      }
    >
      <View style={styles.header}>
        <Text style={styles.greeting}>{getGreeting()}</Text>
        <Text style={styles.title}>TeeTimes Pro</Text>
      </View>

      {/* Quick Book Card */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Quick Book</Text>
        <Text style={styles.cardSubtitle}>Find available tee times near you</Text>
        <Button title="Search Tee Times" onPress={handleSearchTeeTimes} style={styles.cardButton} />
      </View>

      {/* Upcoming Bookings */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Upcoming Rounds</Text>
        {upcomingBookings.length === 0 ? (
          <Text style={styles.cardSubtitle}>No upcoming bookings</Text>
        ) : (
          upcomingBookings.slice(0, 3).map((booking) => (
            <View key={booking.id} style={styles.bookingItem}>
              <View style={styles.bookingLeft}>
                <Text style={styles.bookingTime}>{booking.teeTime.formattedTime}</Text>
                <Text style={styles.bookingDate}>{formatDate(booking.teeTime.startsAt)}</Text>
              </View>
              <View style={styles.bookingRight}>
                <Text style={styles.bookingPlayers}>
                  {booking.playersCount} player{booking.playersCount !== 1 ? 's' : ''}
                </Text>
                <Text style={styles.bookingCode}>{booking.confirmationCode}</Text>
              </View>
            </View>
          ))
        )}
        {upcomingBookings.length > 3 && (
          <Text style={styles.moreText}>+{upcomingBookings.length - 3} more</Text>
        )}
      </View>

      <Button
        title="Sign Out"
        onPress={() => void signOut()}
        variant="outline"
        size="sm"
        style={styles.signOut}
      />
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f9fafb' },
  content: { padding: 16 },
  header: { marginBottom: 24, paddingTop: 8 },
  greeting: { fontSize: 16, color: '#6b7280' },
  title: { fontSize: 28, fontWeight: '700', color: '#1f2937' },
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  cardTitle: { fontSize: 18, fontWeight: '600', color: '#1f2937', marginBottom: 4 },
  cardSubtitle: { fontSize: 14, color: '#6b7280', marginBottom: 12 },
  cardButton: { marginTop: 4 },
  bookingItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f3f4f6',
  },
  bookingLeft: {},
  bookingTime: {
    fontSize: 16,
    fontWeight: '700',
    color: '#1f2937',
  },
  bookingDate: {
    fontSize: 13,
    color: '#6b7280',
    marginTop: 2,
  },
  bookingRight: {
    alignItems: 'flex-end',
  },
  bookingPlayers: {
    fontSize: 14,
    color: '#374151',
  },
  bookingCode: {
    fontSize: 12,
    color: '#16a34a',
    fontWeight: '600',
    marginTop: 2,
  },
  moreText: {
    fontSize: 13,
    color: '#16a34a',
    fontWeight: '600',
    textAlign: 'center',
    paddingTop: 8,
  },
  signOut: { marginTop: 24 },
});
