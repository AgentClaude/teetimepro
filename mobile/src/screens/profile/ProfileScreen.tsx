import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { Button } from '@/components/ui';
import { useAuth } from '@/hooks/useAuth';

export const ProfileScreen: React.FC = () => {
  const { signOut } = useAuth();

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.header}>
        <View style={styles.avatar}>
          <Text style={styles.avatarText}>👤</Text>
        </View>
        <Text style={styles.name}>Golfer</Text>
        <Text style={styles.email}>golfer@example.com</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Account</Text>
        <View style={styles.menuItem}>
          <Text style={styles.menuText}>Edit Profile</Text>
        </View>
        <View style={styles.menuItem}>
          <Text style={styles.menuText}>Booking History</Text>
        </View>
        <View style={styles.menuItem}>
          <Text style={styles.menuText}>Payment Methods</Text>
        </View>
        <View style={styles.menuItem}>
          <Text style={styles.menuText}>Notifications</Text>
        </View>
      </View>

      <Button
        title="Sign Out"
        onPress={signOut}
        variant="outline"
        style={styles.signOut}
      />
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f9fafb' },
  content: { padding: 16 },
  header: { alignItems: 'center', paddingVertical: 24 },
  avatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: '#e5e7eb',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  avatarText: { fontSize: 36 },
  name: { fontSize: 20, fontWeight: '600', color: '#1f2937' },
  email: { fontSize: 14, color: '#6b7280', marginTop: 4 },
  section: { marginTop: 16 },
  sectionTitle: { fontSize: 14, fontWeight: '600', color: '#6b7280', marginBottom: 8, textTransform: 'uppercase' },
  menuItem: {
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 8,
    marginBottom: 4,
  },
  menuText: { fontSize: 16, color: '#1f2937' },
  signOut: { marginTop: 24 },
});
