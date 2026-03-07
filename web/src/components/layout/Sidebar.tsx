import { NavLink } from 'react-router-dom';
import { useCourse } from '../../contexts/CourseContext';
import {
  CalendarDaysIcon,
  ClipboardDocumentListIcon,
  UserGroupIcon,
  ChartBarIcon,
  Cog6ToothIcon,
  HomeIcon,
  MegaphoneIcon,
  BellIcon,
  FunnelIcon,
  PhoneIcon,
  TrophyIcon,
  XMarkIcon,
} from '@heroicons/react/24/outline';

const navigation = [
  { name: 'Dashboard', href: '/', icon: HomeIcon },
  { name: 'Tee Sheet', href: '/tee-sheet', icon: CalendarDaysIcon },
  { name: 'Bookings', href: '/bookings', icon: ClipboardDocumentListIcon },
  { name: 'Customers', href: '/customers', icon: UserGroupIcon },
  { name: 'Tournaments', href: '/tournaments', icon: TrophyIcon },
  { name: 'Notifications', href: '/notifications', icon: BellIcon },
  { name: 'Segments', href: '/segments', icon: FunnelIcon },
  { name: 'Campaigns', href: '/campaigns', icon: MegaphoneIcon },
  { name: 'Reports', href: '/reports', icon: ChartBarIcon },
  { name: 'Voice Analytics', href: '/voice-analytics', icon: PhoneIcon },
  { name: 'Settings', href: '/settings', icon: Cog6ToothIcon },
];

interface SidebarProps {
  onClose?: () => void;
}

export function Sidebar({ onClose }: SidebarProps) {
  const { courses, selectedCourseId, setSelectedCourseId } = useCourse();

  const handleNavClick = () => {
    // Close sidebar on mobile after navigation
    onClose?.();
  };

  return (
    <aside className="flex h-full w-64 flex-col border-r border-gray-200 bg-white">
      {/* Logo + close button */}
      <div className="flex h-16 items-center justify-between border-b px-6">
        <div className="flex items-center gap-2">
          <span className="text-2xl">⛳</span>
          <span className="text-lg font-bold text-gray-900">TeeTimes Pro</span>
        </div>
        {onClose && (
          <button
            onClick={onClose}
            className="rounded-md p-1 text-gray-400 hover:bg-gray-100 hover:text-gray-600 lg:hidden"
          >
            <XMarkIcon className="h-5 w-5" />
          </button>
        )}
      </div>

      {/* Navigation */}
      <nav className="flex-1 space-y-1 overflow-y-auto px-3 py-4">
        {navigation.map((item) => (
          <NavLink
            key={item.name}
            to={item.href}
            onClick={handleNavClick}
            className={({ isActive }) =>
              `flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors ${
                isActive
                  ? 'bg-green-50 text-green-700'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`
            }
          >
            <item.icon className="h-5 w-5 flex-shrink-0" />
            {item.name}
          </NavLink>
        ))}
      </nav>

      {/* Course Selector (bottom) */}
      <div className="border-t p-4">
        <select
          value={selectedCourseId}
          onChange={(e) => setSelectedCourseId(e.target.value)}
          className="w-full rounded-md border-gray-300 text-sm shadow-sm focus:border-green-500 focus:ring-green-500"
        >
          {courses.length === 0 ? (
            <option value="">Loading...</option>
          ) : (
            courses.map((c) => (
              <option key={c.id} value={c.id}>{c.name}</option>
            ))
          )}
        </select>
      </div>
    </aside>
  );
}
