import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { Button } from '@/components/ui';
import { useAuth } from '@/hooks/useAuth';

export const HomeScreen: React.FC = () => {
  const { signOut } = useAuth();

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.header}>
        <Text style={styles.greeting}>Good morning! ⛳</Text>
        <Text style={styles.title}>TeeTimes Pro</Text>
      </View>

      <View style={styles.card}>
        <Text style={styles.cardTitle}>Quick Book</Text>
        <Text style={styles.cardSubtitle}>Find available tee times near you</Text>
        <Button title="Search Tee Times" onPress={() => {}} style={styles.cardButton} />
      </View>

      <View style={styles.card}>
        <Text style={styles.cardTitle}>Upcoming Rounds</Text>
        <Text style={styles.cardSubtitle}>No upcoming bookings</Text>
      </View>

      <Button
        title="Sign Out"
        onPress={signOut}
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
  signOut: { marginTop: 24 },
});
