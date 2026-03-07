import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export const BookingScreen: React.FC = () => {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Book a Tee Time</Text>
      <Text style={styles.subtitle}>Search and book available tee times</Text>
      {/* TODO: Implement search, date picker, course list, tee time grid */}
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f9fafb', padding: 16 },
  title: { fontSize: 24, fontWeight: '700', color: '#1f2937', marginBottom: 4 },
  subtitle: { fontSize: 14, color: '#6b7280' },
});
