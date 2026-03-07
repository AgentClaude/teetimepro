import React, { useState, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
} from 'react-native';
import { useLazyQuery } from '@apollo/client/react';
import { Input } from '@/components/ui';
import { PUBLIC_COURSE_QUERY } from '@/graphql/operations/booking';
import type { BookingScreenProps } from '@/types/navigation';
import type { Course } from '@/types/booking';

interface CourseQueryResult {
  publicCourse: Course | null;
}

export const CourseSearchScreen: React.FC<BookingScreenProps<'CourseSearch'>> = ({ navigation }) => {
  const [slug, setSlug] = useState('');
  const [courses, setCourses] = useState<Course[]>([]);
  const [searchError, setSearchError] = useState<string | null>(null);

  const [searchCourse, { loading }] = useLazyQuery<CourseQueryResult>(PUBLIC_COURSE_QUERY);

  const handleSearch = useCallback(async () => {
    const trimmed = slug.trim().toLowerCase();
    if (!trimmed) return;
    try {
      const { data, error } = await searchCourse({ variables: { slug: trimmed } });
      if (error) {
        setCourses([]);
        setSearchError(error.message);
      } else if (data?.publicCourse) {
        setCourses([data.publicCourse]);
        setSearchError(null);
      } else {
        setCourses([]);
        setSearchError('Course not found. Check the course slug and try again.');
      }
    } catch (err) {
      setCourses([]);
      setSearchError(err instanceof Error ? err.message : 'Search failed');
    }
  }, [slug, searchCourse]);

  const handleSelectCourse = useCallback(
    (course: Course) => {
      navigation.navigate('TeeTimeSelect', {
        courseSlug: course.slug,
        courseName: course.name,
      });
    },
    [navigation]
  );

  const renderCourse = useCallback(
    ({ item }: { item: Course }) => (
      <TouchableOpacity
        style={styles.courseCard}
        onPress={() => handleSelectCourse(item)}
        activeOpacity={0.7}
      >
        <View style={styles.courseInfo}>
          <Text style={styles.courseName}>{item.name}</Text>
          {item.address && <Text style={styles.courseAddress}>{item.address}</Text>}
          <View style={styles.courseDetails}>
            <Text style={styles.courseDetail}>{item.holes} holes</Text>
            <Text style={styles.courseDetail}>•</Text>
            <Text style={styles.courseDetail}>
              {item.firstTeeTime} - {item.lastTeeTime}
            </Text>
          </View>
          {item.weekdayRateCents != null && (
            <Text style={styles.courseRate}>
              From ${(item.weekdayRateCents / 100).toFixed(0)}/round
            </Text>
          )}
        </View>
        <Text style={styles.chevron}>›</Text>
      </TouchableOpacity>
    ),
    [handleSelectCourse]
  );

  return (
    <View style={styles.container}>
      <View style={styles.searchContainer}>
        <Input
          label="Course Slug"
          value={slug}
          onChangeText={setSlug}
          placeholder="e.g. pine-valley"
          autoCapitalize="none"
          autoCorrect={false}
          returnKeyType="search"
          onSubmitEditing={() => void handleSearch()}
        />
        <TouchableOpacity
          style={[styles.searchButton, (!slug.trim() || loading) && styles.searchButtonDisabled]}
          onPress={() => void handleSearch()}
          disabled={!slug.trim() || loading}
          activeOpacity={0.7}
        >
          {loading ? (
            <ActivityIndicator color="#ffffff" size="small" />
          ) : (
            <Text style={styles.searchButtonText}>Search</Text>
          )}
        </TouchableOpacity>
      </View>

      {searchError && (
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>{searchError}</Text>
        </View>
      )}

      <FlatList
        data={courses}
        keyExtractor={(item) => item.id}
        renderItem={renderCourse}
        contentContainerStyle={styles.listContent}
        ListEmptyComponent={
          !loading && !searchError ? (
            <View style={styles.emptyContainer}>
              <Text style={styles.emptyTitle}>Find Your Course</Text>
              <Text style={styles.emptyText}>
                Enter a course slug to search for available tee times.
              </Text>
            </View>
          ) : null
        }
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb',
  },
  searchContainer: {
    padding: 16,
    backgroundColor: '#ffffff',
    borderBottomWidth: 1,
    borderBottomColor: '#e5e7eb',
  },
  searchButton: {
    backgroundColor: '#16a34a',
    borderRadius: 8,
    paddingVertical: 12,
    alignItems: 'center',
    marginTop: 8,
  },
  searchButtonDisabled: {
    opacity: 0.5,
  },
  searchButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  listContent: {
    padding: 16,
  },
  courseCard: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    flexDirection: 'row',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 3,
    elevation: 2,
  },
  courseInfo: {
    flex: 1,
  },
  courseName: {
    fontSize: 18,
    fontWeight: '700',
    color: '#1f2937',
    marginBottom: 4,
  },
  courseAddress: {
    fontSize: 14,
    color: '#6b7280',
    marginBottom: 6,
  },
  courseDetails: {
    flexDirection: 'row',
    gap: 6,
    marginBottom: 4,
  },
  courseDetail: {
    fontSize: 13,
    color: '#9ca3af',
  },
  courseRate: {
    fontSize: 14,
    fontWeight: '600',
    color: '#16a34a',
    marginTop: 4,
  },
  chevron: {
    fontSize: 24,
    color: '#9ca3af',
    marginLeft: 8,
  },
  errorContainer: {
    margin: 16,
    padding: 12,
    backgroundColor: '#fef2f2',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#fecaca',
  },
  errorText: {
    color: '#dc2626',
    fontSize: 14,
  },
  emptyContainer: {
    alignItems: 'center',
    paddingVertical: 48,
  },
  emptyTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#1f2937',
    marginBottom: 8,
  },
  emptyText: {
    fontSize: 14,
    color: '#6b7280',
    textAlign: 'center',
    paddingHorizontal: 32,
  },
});
