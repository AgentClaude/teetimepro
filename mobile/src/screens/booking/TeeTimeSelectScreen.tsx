import React, { useState, useCallback, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  Platform,
} from 'react-native';
import { useQuery } from '@apollo/client/react';
import { PUBLIC_AVAILABLE_TEE_TIMES_QUERY } from '@/graphql/operations/booking';
import { formatCents, todayISO } from '@/utils/format';
import type { BookingScreenProps } from '@/types/navigation';
import type { TeeTime, TimePreference } from '@/types/booking';

interface TeeTimesQueryResult {
  publicAvailableTeeTimes: TeeTime[];
}

const TIME_FILTERS: { label: string; value: TimePreference }[] = [
  { label: 'All', value: null },
  { label: 'Morning', value: 'morning' },
  { label: 'Afternoon', value: 'afternoon' },
  { label: 'Twilight', value: 'twilight' },
];

const PLAYER_OPTIONS = [1, 2, 3, 4] as const;

export const TeeTimeSelectScreen: React.FC<BookingScreenProps<'TeeTimeSelect'>> = ({
  navigation,
  route,
}) => {
  const { courseSlug, courseName } = route.params;
  const [selectedDate, setSelectedDate] = useState(todayISO());
  const [players, setPlayers] = useState(2);
  const [timePreference, setTimePreference] = useState<TimePreference>(null);

  const { data, loading, error, refetch } = useQuery<TeeTimesQueryResult>(
    PUBLIC_AVAILABLE_TEE_TIMES_QUERY,
    {
      variables: {
        courseSlug,
        date: selectedDate,
        players,
        timePreference,
      },
      fetchPolicy: 'cache-and-network',
    }
  );

  const teeTimes = data?.publicAvailableTeeTimes ?? [];

  // Generate next 7 days for date picker
  const dateOptions = useMemo(() => {
    const dates: { date: string; label: string; dayLabel: string }[] = [];
    const today = new Date();
    for (let i = 0; i < 7; i++) {
      const d = new Date(today);
      d.setDate(d.getDate() + i);
      const iso = d.toISOString().split('T')[0]!;
      dates.push({
        date: iso,
        label: d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
        dayLabel: i === 0 ? 'Today' : i === 1 ? 'Tomorrow' : d.toLocaleDateString('en-US', { weekday: 'short' }),
      });
    }
    return dates;
  }, []);

  const handleSelectTeeTime = useCallback(
    (teeTime: TeeTime) => {
      navigation.navigate('BookingConfirm', {
        courseSlug,
        courseName,
        teeTimeId: teeTime.id,
        formattedTime: teeTime.formattedTime,
        startsAt: teeTime.startsAt,
        priceCents: teeTime.priceCents,
        dynamicPriceCents: teeTime.dynamicPriceCents,
        availableSpots: teeTime.availableSpots,
      });
    },
    [navigation, courseSlug, courseName]
  );

  const renderTeeTime = useCallback(
    ({ item }: { item: TeeTime }) => {
      const displayPrice = item.hasDynamicPricing ? item.dynamicPriceCents : item.priceCents;

      return (
        <TouchableOpacity
          style={styles.teeTimeCard}
          onPress={() => handleSelectTeeTime(item)}
          activeOpacity={0.7}
        >
          <View style={styles.teeTimeLeft}>
            <Text style={styles.teeTimeTime}>{item.formattedTime}</Text>
            <Text style={styles.teeTimeSpots}>
              {item.availableSpots} spot{item.availableSpots !== 1 ? 's' : ''} left
            </Text>
          </View>
          <View style={styles.teeTimeRight}>
            <Text style={styles.teeTimePrice}>{formatCents(displayPrice)}</Text>
            {item.hasDynamicPricing && (
              <Text style={styles.teeTimeOrigPrice}>{formatCents(item.priceCents)}</Text>
            )}
            <Text style={styles.perPlayer}>per player</Text>
          </View>
        </TouchableOpacity>
      );
    },
    [handleSelectTeeTime]
  );

  return (
    <View style={styles.container}>
      {/* Date Picker */}
      <View style={styles.datePickerContainer}>
        <FlatList
          horizontal
          data={dateOptions}
          keyExtractor={(item) => item.date}
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.datePickerContent}
          renderItem={({ item }) => (
            <TouchableOpacity
              style={[styles.dateChip, selectedDate === item.date && styles.dateChipSelected]}
              onPress={() => setSelectedDate(item.date)}
              activeOpacity={0.7}
            >
              <Text
                style={[styles.dateChipDay, selectedDate === item.date && styles.dateChipTextSelected]}
              >
                {item.dayLabel}
              </Text>
              <Text
                style={[styles.dateChipDate, selectedDate === item.date && styles.dateChipTextSelected]}
              >
                {item.label}
              </Text>
            </TouchableOpacity>
          )}
        />
      </View>

      {/* Player Count */}
      <View style={styles.filterRow}>
        <Text style={styles.filterLabel}>Players</Text>
        <View style={styles.playerOptions}>
          {PLAYER_OPTIONS.map((n) => (
            <TouchableOpacity
              key={n}
              style={[styles.playerChip, players === n && styles.playerChipSelected]}
              onPress={() => setPlayers(n)}
              activeOpacity={0.7}
            >
              <Text style={[styles.playerChipText, players === n && styles.playerChipTextSelected]}>
                {n}
              </Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      {/* Time Filter */}
      <View style={styles.filterRow}>
        <Text style={styles.filterLabel}>Time</Text>
        <View style={styles.playerOptions}>
          {TIME_FILTERS.map((f) => (
            <TouchableOpacity
              key={f.label}
              style={[styles.timeChip, timePreference === f.value && styles.playerChipSelected]}
              onPress={() => setTimePreference(f.value)}
              activeOpacity={0.7}
            >
              <Text
                style={[
                  styles.playerChipText,
                  timePreference === f.value && styles.playerChipTextSelected,
                ]}
              >
                {f.label}
              </Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      {/* Tee Times List */}
      {loading && teeTimes.length === 0 ? (
        <View style={styles.centered}>
          <ActivityIndicator size="large" color="#16a34a" />
          <Text style={styles.loadingText}>Finding tee times...</Text>
        </View>
      ) : error ? (
        <View style={styles.centered}>
          <Text style={styles.errorText}>Failed to load tee times</Text>
          <TouchableOpacity style={styles.retryButton} onPress={() => void refetch()}>
            <Text style={styles.retryText}>Retry</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <FlatList
          data={teeTimes}
          keyExtractor={(item) => item.id}
          renderItem={renderTeeTime}
          contentContainerStyle={styles.listContent}
          refreshing={loading}
          onRefresh={() => void refetch()}
          ListEmptyComponent={
            <View style={styles.centered}>
              <Text style={styles.emptyTitle}>No Tee Times Available</Text>
              <Text style={styles.emptyText}>
                Try a different date or adjust your filters.
              </Text>
            </View>
          }
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb',
  },
  datePickerContainer: {
    backgroundColor: '#ffffff',
    borderBottomWidth: 1,
    borderBottomColor: '#e5e7eb',
    paddingVertical: 12,
  },
  datePickerContent: {
    paddingHorizontal: 12,
    gap: 8,
  },
  dateChip: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 20,
    backgroundColor: '#f3f4f6',
    alignItems: 'center',
    minWidth: 72,
  },
  dateChipSelected: {
    backgroundColor: '#16a34a',
  },
  dateChipDay: {
    fontSize: 12,
    fontWeight: '600',
    color: '#6b7280',
  },
  dateChipDate: {
    fontSize: 14,
    fontWeight: '700',
    color: '#1f2937',
    marginTop: 2,
  },
  dateChipTextSelected: {
    color: '#ffffff',
  },
  filterRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 10,
    backgroundColor: '#ffffff',
    borderBottomWidth: 1,
    borderBottomColor: '#e5e7eb',
  },
  filterLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: '#374151',
    width: 60,
  },
  playerOptions: {
    flexDirection: 'row',
    gap: 8,
    flex: 1,
  },
  playerChip: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#f3f4f6',
    alignItems: 'center',
    justifyContent: 'center',
  },
  playerChipSelected: {
    backgroundColor: '#16a34a',
  },
  playerChipText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#374151',
  },
  playerChipTextSelected: {
    color: '#ffffff',
  },
  timeChip: {
    paddingHorizontal: 14,
    height: 36,
    borderRadius: 18,
    backgroundColor: '#f3f4f6',
    alignItems: 'center',
    justifyContent: 'center',
  },
  listContent: {
    padding: 16,
  },
  teeTimeCard: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 10,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 3,
    elevation: 2,
  },
  teeTimeLeft: {
    flex: 1,
  },
  teeTimeTime: {
    fontSize: 20,
    fontWeight: '700',
    color: '#1f2937',
  },
  teeTimeSpots: {
    fontSize: 13,
    color: '#6b7280',
    marginTop: 2,
  },
  teeTimeRight: {
    alignItems: 'flex-end',
  },
  teeTimePrice: {
    fontSize: 18,
    fontWeight: '700',
    color: '#16a34a',
  },
  teeTimeOrigPrice: {
    fontSize: 13,
    color: '#9ca3af',
    textDecorationLine: 'line-through',
  },
  perPlayer: {
    fontSize: 11,
    color: '#9ca3af',
    marginTop: 2,
  },
  centered: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 48,
  },
  loadingText: {
    marginTop: 12,
    fontSize: 14,
    color: '#6b7280',
  },
  errorText: {
    fontSize: 16,
    color: '#dc2626',
    marginBottom: 12,
  },
  retryButton: {
    paddingHorizontal: 20,
    paddingVertical: 10,
    backgroundColor: '#16a34a',
    borderRadius: 8,
  },
  retryText: {
    color: '#ffffff',
    fontWeight: '600',
  },
  emptyTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#1f2937',
    marginBottom: 4,
  },
  emptyText: {
    fontSize: 14,
    color: '#6b7280',
    textAlign: 'center',
    paddingHorizontal: 32,
  },
});
