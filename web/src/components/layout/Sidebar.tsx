import { NavLink } from 'react-router-dom';
import { useQuery } from '@apollo/client';
import { GET_COURSES } from '../../graphql/queries';
import {
  CalendarDaysIcon,
  ClipboardDocumentListIcon,
  UserGroupIcon,
  ChartBarIcon,
  Cog6ToothIcon,
  HomeIcon,
  MegaphoneIcon,
} from '@heroicons/react/24/outline';

const navigation = [
  { name: 'Dashboard', href: '/', icon: HomeIcon },
  { name: 'Tee Sheet', href: '/tee-sheet', icon: CalendarDaysIcon },
  { name: 'Bookings', href: '/bookings', icon: ClipboardDocumentListIcon },
  { name: 'Customers', href: '/customers', icon: UserGroupIcon },
  { name: 'Campaigns', href: '/campaigns', icon: MegaphoneIcon },
  { name: 'Reports', href: '/reports', icon: ChartBarIcon },
  { name: 'Settings', href: '/settings', icon: Cog6ToothIcon },
];

export function Sidebar() {
  const { data } = useQuery(GET_COURSES);
  const courses = data?.courses || [];

  const storedCourseId = localStorage.getItem('selectedCourseId') || '';
  const selectedId = storedCourseId && courses.some((c: { id: string }) => c.id === storedCourseId)
    ? storedCourseId
    : courses[0]?.id || '';

  function handleCourseChange(e: React.ChangeEvent<HTMLSelectElement>) {
    localStorage.setItem('selectedCourseId', e.target.value);
    window.dispatchEvent(new Event('courseChanged'));
  }

  return (
    <aside className="flex h-full w-64 flex-col border-r border-gray-200 bg-white">
      {/* Logo */}
      <div className="flex h-16 items-center gap-2 border-b px-6">
        <span className="text-2xl">⛳</span>
        <span className="text-lg font-bold text-gray-900">TeeTimes Pro</span>
      </div>

      {/* Navigation */}
      <nav className="flex-1 space-y-1 px-3 py-4">
        {navigation.map((item) => (
          <NavLink
            key={item.name}
            to={item.href}
            className={({ isActive }) =>
              `flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors ${
                isActive
                  ? 'bg-green-50 text-green-700'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`
            }
          >
            <item.icon className="h-5 w-5" />
            {item.name}
          </NavLink>
        ))}
      </nav>

      {/* Course Selector (bottom) */}
      <div className="border-t p-4">
        <select
          value={selectedId}
          onChange={handleCourseChange}
          className="w-full rounded-md border-gray-300 text-sm shadow-sm focus:border-green-500 focus:ring-green-500"
        >
          {courses.length === 0 ? (
            <option value="">Loading...</option>
          ) : (
            courses.map((c: { id: string; name: string }) => (
              <option key={c.id} value={c.id}>{c.name}</option>
            ))
          )}
        </select>
      </div>
    </aside>
  );
}
