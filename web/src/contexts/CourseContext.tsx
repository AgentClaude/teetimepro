import { createContext, useContext, useState, useEffect, type ReactNode } from 'react';
import { useQuery } from '@apollo/client';
import { GET_COURSES } from '../graphql/queries';
import type { Course } from '../types';

interface CourseContextValue {
  courses: Course[];
  selectedCourseId: string;
  selectedCourse: Course | null;
  setSelectedCourseId: (id: string) => void;
  loading: boolean;
}

const CourseContext = createContext<CourseContextValue>({
  courses: [],
  selectedCourseId: '',
  selectedCourse: null,
  setSelectedCourseId: () => {},
  loading: true,
});

export function CourseProvider({ children }: { children: ReactNode }) {
  const { data, loading } = useQuery(GET_COURSES);
  const courses: Course[] = data?.courses || [];

  const [selectedCourseId, setSelectedCourseIdState] = useState<string>(() => {
    return localStorage.getItem('selectedCourseId') || '';
  });

  // Auto-select first course when courses load
  useEffect(() => {
    if (courses.length > 0 && !courses.some((c) => c.id === selectedCourseId)) {
      setSelectedCourseIdState(courses[0].id);
      localStorage.setItem('selectedCourseId', courses[0].id);
    }
  }, [courses, selectedCourseId]);

  function setSelectedCourseId(id: string) {
    setSelectedCourseIdState(id);
    localStorage.setItem('selectedCourseId', id);
  }

  const selectedCourse = courses.find((c) => c.id === selectedCourseId) || null;

  return (
    <CourseContext.Provider value={{ courses, selectedCourseId, selectedCourse, setSelectedCourseId, loading }}>
      {children}
    </CourseContext.Provider>
  );
}

export function useCourse() {
  return useContext(CourseContext);
}
