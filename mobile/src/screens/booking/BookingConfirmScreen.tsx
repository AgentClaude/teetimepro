import React, { useState, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Alert,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { useMutation } from '@apollo/client/react';
import { Button, Input } from '@/components/ui';
import { CREATE_PUBLIC_BOOKING_MUTATION } from '@/graphql/operations/booking';
import { formatCents, formatDate } from '@/utils/format';
import type { BookingScreenProps } from '@/types/navigation';

interface BookingResult {
  createPublicBooking: {
    booking: {
      id: string;
      confirmationCode: string;
      status: string;
      playersCount: number;
      totalCents: number;
    } | null;
    errors: string[];
  };
}

const PLAYER_OPTIONS = [1, 2, 3, 4] as const;

export const BookingConfirmScreen: React.FC<BookingScreenProps<'BookingConfirm'>> = ({
  navigation,
  route,
}) => {
  const {
    courseSlug,
    courseName,
    teeTimeId,
    formattedTime,
    startsAt,
    priceCents,
    dynamicPriceCents,
    availableSpots,
  } = route.params;

  const effectivePrice = dynamicPriceCents ?? priceCents;
  const dateStr = formatDate(startsAt);

  const [playersCount, setPlayersCount] = useState(Math.min(2, availableSpots));
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [formError, setFormError] = useState<string | null>(null);

  const totalCents = (effectivePrice ?? 0) * playersCount;

  const [createBooking, { loading }] = useMutation<BookingResult>(CREATE_PUBLIC_BOOKING_MUTATION);

  const validate = useCallback((): boolean => {
    if (!name.trim()) {
      setFormError('Please enter your name.');
      return false;
    }
    if (!email.trim() || !email.includes('@')) {
      setFormError('Please enter a valid email address.');
      return false;
    }
    if (!phone.trim() || phone.replace(/\D/g, '').length < 10) {
      setFormError('Please enter a valid phone number.');
      return false;
    }
    setFormError(null);
    return true;
  }, [name, email, phone]);

  const handleBook = useCallback(async () => {
    if (!validate()) return;

    try {
      const { data } = await createBooking({
        variables: {
          courseSlug,
          teeTimeId,
          playersCount,
          customerName: name.trim(),
          customerEmail: email.trim().toLowerCase(),
          customerPhone: phone.trim(),
        },
      });

      const result = data?.createPublicBooking;
      if (result?.booking) {
        navigation.navigate('BookingSuccess', {
          confirmationCode: result.booking.confirmationCode,
          courseName,
          formattedTime,
          startsAt,
          playersCount: result.booking.playersCount,
          totalCents: result.booking.totalCents,
        });
      } else if (result?.errors.length) {
        Alert.alert('Booking Failed', result.errors.join('\n'));
      }
    } catch (err) {
      Alert.alert('Error', err instanceof Error ? err.message : 'Something went wrong');
    }
  }, [
    validate,
    createBooking,
    courseSlug,
    teeTimeId,
    playersCount,
    name,
    email,
    phone,
    navigation,
    courseName,
    formattedTime,
    startsAt,
  ]);

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView contentContainerStyle={styles.scrollContent} keyboardShouldPersistTaps="handled">
        {/* Booking Summary */}
        <View style={styles.summaryCard}>
          <Text style={styles.summaryTitle}>{courseName}</Text>
          <View style={styles.summaryRow}>
            <Text style={styles.summaryLabel}>Date</Text>
            <Text style={styles.summaryValue}>{dateStr}</Text>
          </View>
          <View style={styles.summaryRow}>
            <Text style={styles.summaryLabel}>Tee Time</Text>
            <Text style={styles.summaryValue}>{formattedTime}</Text>
          </View>
          <View style={styles.summaryRow}>
            <Text style={styles.summaryLabel}>Rate</Text>
            <Text style={styles.summaryValue}>{formatCents(effectivePrice)} / player</Text>
          </View>
        </View>

        {/* Player Count */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Number of Players</Text>
          <View style={styles.playerOptions}>
            {PLAYER_OPTIONS.filter((n) => n <= availableSpots).map((n) => (
              <Button
                key={n}
                title={String(n)}
                variant={playersCount === n ? 'primary' : 'outline'}
                size="sm"
                onPress={() => setPlayersCount(n)}
                style={styles.playerButton}
              />
            ))}
          </View>
        </View>

        {/* Contact Info */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Your Details</Text>
          <Input
            label="Full Name"
            value={name}
            onChangeText={setName}
            placeholder="John Smith"
            autoCapitalize="words"
          />
          <Input
            label="Email"
            value={email}
            onChangeText={setEmail}
            placeholder="john@example.com"
            keyboardType="email-address"
            autoCapitalize="none"
            autoCorrect={false}
          />
          <Input
            label="Phone"
            value={phone}
            onChangeText={setPhone}
            placeholder="(555) 123-4567"
            keyboardType="phone-pad"
          />
        </View>

        {formError && (
          <View style={styles.errorContainer}>
            <Text style={styles.errorText}>{formError}</Text>
          </View>
        )}

        {/* Total & Book Button */}
        <View style={styles.totalContainer}>
          <View style={styles.totalRow}>
            <Text style={styles.totalLabel}>Total</Text>
            <Text style={styles.totalValue}>{formatCents(totalCents)}</Text>
          </View>
          <Text style={styles.totalBreakdown}>
            {playersCount} player{playersCount !== 1 ? 's' : ''} × {formatCents(effectivePrice)}
          </Text>
        </View>

        <Button
          title={loading ? 'Booking...' : 'Confirm Booking'}
          onPress={() => void handleBook()}
          loading={loading}
          disabled={loading}
          size="lg"
          style={styles.bookButton}
        />
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb',
  },
  scrollContent: {
    padding: 16,
  },
  summaryCard: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 3,
    elevation: 2,
  },
  summaryTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#1f2937',
    marginBottom: 12,
  },
  summaryRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 6,
    borderBottomWidth: 1,
    borderBottomColor: '#f3f4f6',
  },
  summaryLabel: {
    fontSize: 14,
    color: '#6b7280',
  },
  summaryValue: {
    fontSize: 14,
    fontWeight: '600',
    color: '#1f2937',
  },
  section: {
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: '#1f2937',
    marginBottom: 12,
  },
  playerOptions: {
    flexDirection: 'row',
    gap: 10,
  },
  playerButton: {
    minWidth: 52,
  },
  errorContainer: {
    padding: 12,
    backgroundColor: '#fef2f2',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#fecaca',
    marginBottom: 16,
  },
  errorText: {
    color: '#dc2626',
    fontSize: 14,
  },
  totalContainer: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 3,
    elevation: 2,
  },
  totalRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  totalLabel: {
    fontSize: 18,
    fontWeight: '700',
    color: '#1f2937',
  },
  totalValue: {
    fontSize: 24,
    fontWeight: '800',
    color: '#16a34a',
  },
  totalBreakdown: {
    fontSize: 13,
    color: '#9ca3af',
    marginTop: 4,
    textAlign: 'right',
  },
  bookButton: {
    marginBottom: 32,
  },
});
