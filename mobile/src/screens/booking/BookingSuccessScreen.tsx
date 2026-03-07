import React, { useCallback } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Button } from '@/components/ui';
import { formatCents, formatDate } from '@/utils/format';
import type { BookingScreenProps } from '@/types/navigation';

export const BookingSuccessScreen: React.FC<BookingScreenProps<'BookingSuccess'>> = ({
  navigation,
  route,
}) => {
  const { confirmationCode, courseName, formattedTime, startsAt, playersCount, totalCents } =
    route.params;

  const handleDone = useCallback(() => {
    // Reset to the course search screen
    navigation.popToTop();
  }, [navigation]);

  const handleViewBookings = useCallback(() => {
    // Navigate to home tab to see bookings
    navigation.getParent()?.navigate('HomeTab');
  }, [navigation]);

  return (
    <View style={styles.container}>
      <View style={styles.content}>
        {/* Success Icon */}
        <View style={styles.iconContainer}>
          <Text style={styles.checkmark}>✓</Text>
        </View>

        <Text style={styles.title}>Booking Confirmed!</Text>
        <Text style={styles.subtitle}>You're all set for your round.</Text>

        {/* Confirmation Details */}
        <View style={styles.detailsCard}>
          <View style={styles.confirmationRow}>
            <Text style={styles.confirmationLabel}>Confirmation</Text>
            <Text style={styles.confirmationCode}>{confirmationCode}</Text>
          </View>

          <View style={styles.divider} />

          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Course</Text>
            <Text style={styles.detailValue}>{courseName}</Text>
          </View>
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Date</Text>
            <Text style={styles.detailValue}>{formatDate(startsAt)}</Text>
          </View>
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Tee Time</Text>
            <Text style={styles.detailValue}>{formattedTime}</Text>
          </View>
          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Players</Text>
            <Text style={styles.detailValue}>{playersCount}</Text>
          </View>

          <View style={styles.divider} />

          <View style={styles.detailRow}>
            <Text style={styles.totalLabel}>Total Paid</Text>
            <Text style={styles.totalValue}>{formatCents(totalCents)}</Text>
          </View>
        </View>

        <Text style={styles.emailNote}>
          A confirmation email has been sent with your booking details.
        </Text>
      </View>

      <View style={styles.buttonContainer}>
        <Button title="View My Bookings" onPress={handleViewBookings} style={styles.button} />
        <Button
          title="Book Another Tee Time"
          onPress={handleDone}
          variant="outline"
          style={styles.button}
        />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb',
  },
  content: {
    flex: 1,
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingTop: 48,
  },
  iconContainer: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: '#dcfce7',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 20,
  },
  checkmark: {
    fontSize: 40,
    color: '#16a34a',
    fontWeight: '700',
  },
  title: {
    fontSize: 26,
    fontWeight: '800',
    color: '#1f2937',
    marginBottom: 6,
  },
  subtitle: {
    fontSize: 16,
    color: '#6b7280',
    marginBottom: 28,
  },
  detailsCard: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 20,
    width: '100%',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 6,
    elevation: 3,
  },
  confirmationRow: {
    alignItems: 'center',
    paddingBottom: 12,
  },
  confirmationLabel: {
    fontSize: 12,
    color: '#9ca3af',
    textTransform: 'uppercase',
    letterSpacing: 1,
    marginBottom: 4,
  },
  confirmationCode: {
    fontSize: 22,
    fontWeight: '800',
    color: '#16a34a',
    letterSpacing: 2,
  },
  divider: {
    height: 1,
    backgroundColor: '#f3f4f6',
    marginVertical: 12,
  },
  detailRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 6,
  },
  detailLabel: {
    fontSize: 14,
    color: '#6b7280',
  },
  detailValue: {
    fontSize: 14,
    fontWeight: '600',
    color: '#1f2937',
  },
  totalLabel: {
    fontSize: 16,
    fontWeight: '700',
    color: '#1f2937',
  },
  totalValue: {
    fontSize: 18,
    fontWeight: '800',
    color: '#16a34a',
  },
  emailNote: {
    fontSize: 13,
    color: '#9ca3af',
    textAlign: 'center',
    marginTop: 16,
    paddingHorizontal: 20,
  },
  buttonContainer: {
    padding: 24,
    paddingBottom: 40,
  },
  button: {
    marginBottom: 10,
  },
});
